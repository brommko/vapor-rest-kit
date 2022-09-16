//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 08.08.2021.
//

import Vapor
import Fluent

public extension ResourceController {
    func read<Model>(req: Request,
                      queryModifier: QueryModifier<Model> = .empty) async throws -> Output
    where
        Output.Model == Model {

        try await Model
            .findByIdKey(req, database: req.db, queryModifier: queryModifier)
            .flatMapThrowing { model in try Output(model, req: req) }
    }
}

public extension RelatedResourceController {
    func read<Model, RelatedModel>(
        resolver: ChildResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throw -> Output
    where
        Model == Output.Model {

        try resolver
            .find(req, req.db, relationKeyPath, queryModifier)
            .flatMapThrowing { (model, related) in try Output(model, req: req) }
    }

    func read<Model, RelatedModel>(
        resolver: ParentResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) async throw -> Output
    where
        Model == Output.Model {

        try resolver
            .find(req, req.db, relationKeyPath, queryModifier)
            .flatMapThrowing { (model, related) in try Output(model, req: req)}
    }

    func read<Model, RelatedModel, Through>(
        resolver: SiblingsResolver<Model, RelatedModel, Through> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) async throw -> Output
    where
        Model == Output.Model {

        try resolver
            .find(req, req.db, relationKeyPath, queryModifier)
            .flatMapThrowing { (model, related) in try Output(model, req: req) }
    }
}

