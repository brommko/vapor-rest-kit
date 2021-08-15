//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 08.08.2021.
//

import Vapor
import Fluent

extension ResourceController {
    func read<Output>(req: Request,
                      queryModifier: QueryModifier<Model>) throws -> EventLoopFuture<Output> where
        Output: ResourceOutputModel,
        Output.Model == Model {

        try Model
            .findByIdKey(req, database: req.db, queryModifier: queryModifier)
            .flatMapThrowing { model in try Output(model, req: req) }
    }
}

extension RelatedResourceController {
    func read<Output, RelatedModel>(
        resolver: ParentChildResolver<Model, RelatedModel>,
        req: Request,
        queryModifier: QueryModifier<Model>,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) throws -> EventLoopFuture<Output>
    where
        Output: ResourceOutputModel,
        Model == Output.Model {

        try resolver
            .find(req, req.db, relationKeyPath, queryModifier)
            .flatMapThrowing { (model, related) in try Output(model, req: req) }

    }

    func read<Output, RelatedModel>(
        resolver: ChildParentResolver<Model, RelatedModel>,
        req: Request,
        queryModifier: QueryModifier<Model>,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) throws -> EventLoopFuture<Output>
    where
        Output: ResourceOutputModel,
        Model == Output.Model {

        try resolver
            .find(req, req.db, relationKeyPath, queryModifier)
            .flatMapThrowing { (model, related) in try Output(model, req: req)}

    }

    func read<Output, RelatedModel, Through>(
        resolver: SiblingsPairResolver<Model, RelatedModel, Through>,
        req: Request,
        queryModifier: QueryModifier<Model>,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) throws -> EventLoopFuture<Output>
    where
        Output: ResourceOutputModel,
        Model == Output.Model {

        try resolver
            .find(req, req.db, relationKeyPath, queryModifier)
            .flatMapThrowing { (model, related) in try Output(model, req: req) }

    }
}

