//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18.07.2021.
//

import Vapor
import Fluent


extension Model where IDValue: LosslessStringConvertible {

    static func create<Input, Output>(req: Request, using: Input.Type) throws -> EventLoopFuture<Output> where
        Input: ResourceUpdateModel,
        Output: ResourceOutputModel,
        Output.Model == Self,
        Input.Model == Output.Model,
        Output.Model: ResourceOutputModel {

        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)

        return req.db.tryTransaction { db in
            inputModel
                .update(Output.Model(), req: req, database: db)
                .flatMap { $0.save(on: db).transform(to: $0) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
}

extension Model where IDValue: LosslessStringConvertible {

    static func createRelated<Input, Output, RelatedModel>(
        req: Request,
        using: Input.Type,
        relatedResourceMiddleware: RelatedResourceControllerMiddleware<Self, RelatedModel> = .defaultMiddleware,
        childrenKeyPath: ChildrenKeyPath<RelatedModel, Self>) throws -> EventLoopFuture<Output>
        where

        Input: ResourceUpdateModel,
        Output: ResourceOutputModel,
        Output.Model: Fluent.Model,
        Output.Model.IDValue: LosslessStringConvertible,
        Self == Output.Model,
        Input.Model == Output.Model,
        Output.Model: ResourceOutputModel,
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {


        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        return req.db.tryTransaction { db in

            try Self.findRelatedWithRootId(req, database: db)
                .and(inputModel.update(Output.Model(), req: req, database: db))
                .flatMap { relatedResourceMiddleware.handleRelated($0.1, relatedModel: $0.0, req: req, database: db) }
                .flatMapThrowing { try $0.0.attached(to: $0.1, with: childrenKeyPath) }
                .flatMap { $0.save(on: db).transform(to: $0) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }

    static func createRelated<Input, Output, RelatedModel>(
        req: Request,
        using: Input.Type,
        relatedResourceMiddleware: RelatedResourceControllerMiddleware<Self, RelatedModel> = .defaultMiddleware,
        childrenKeyPath: ChildrenKeyPath<Self, RelatedModel>) throws -> EventLoopFuture<Output>
        where

        Input: ResourceUpdateModel,
        Output: ResourceOutputModel,
        Output.Model: Fluent.Model,
        Output.Model.IDValue: LosslessStringConvertible,
        Self == Output.Model,
        Input.Model == Output.Model,
        Output.Model: ResourceOutputModel,
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {


        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        let keyPath = childrenKeyPath
        return req.db.tryTransaction { db in

            try Self.findRelatedWithRootId(req, database: db)
                    .and(inputModel.update(Output.Model(), req: req, database: db))
                    .flatMap { relatedResourceMiddleware.handleRelated($0.1, relatedModel: $0.0, req: req, database: db) }
                    .flatMap { (model, related) in  model.save(on: db).transform(to: (model, related)) }
                    .flatMapThrowing { (model, related) in (try model.attached(to: related, with: keyPath), related) }
                    .flatMap { (model, related) in [related.save(on: db), model.save(on: db)]
                        .flatten(on: db.context.eventLoop)
                        .transform(to: model) }
                    .flatMapThrowing { try Output($0, req: req)}
        }
    }

    static func createRelated<Input, Output, RelatedModel, Through>(
        req: Request,
        using: Input.Type,
        relatedResourceMiddleware: RelatedResourceControllerMiddleware<Self, RelatedModel> = .defaultMiddleware,
        siblingKeyPath: SiblingKeyPath<RelatedModel, Self, Through>) throws -> EventLoopFuture<Output>
        where

        Input: ResourceUpdateModel,
        Output: ResourceOutputModel,
        Output.Model: Fluent.Model,
        Through: Fluent.Model,
        Output.Model.IDValue: LosslessStringConvertible,
        Self == Output.Model,
        Input.Model == Output.Model,
        Output.Model: ResourceOutputModel,
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        return req.db.tryTransaction { db in

            try Self.findRelatedWithRootId(req, database: db)
                .and(inputModel.update(Output.Model(), req: req, database: db))
                .flatMap { relatedResourceMiddleware.handleRelated($0.1, relatedModel: $0.0, req: req, database: db) }
                .flatMap { (model, related) in model.save(on: db).transform(to: (model, related)) }
                .flatMap { (model, related) in model.attached(to: related, with: siblingKeyPath, on: db) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
}



extension Model where IDValue: LosslessStringConvertible {

    static func createAuthRelated<Input, Output, RelatedModel>(
        req: Request,
        using: Input.Type,
        relatedResourceMiddleware: RelatedResourceControllerMiddleware<Self, RelatedModel> = .defaultMiddleware,
        childrenKeyPath: ChildrenKeyPath<RelatedModel, Self>) throws -> EventLoopFuture<Output>
        where

        Input: ResourceUpdateModel,
        Output: ResourceOutputModel,
        Output.Model: Fluent.Model,
        Output.Model.IDValue: LosslessStringConvertible,
        Self == Output.Model,
        Input.Model == Output.Model,
        Output.Model: ResourceOutputModel,
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {


        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        return req.db.tryTransaction { db in

            try Self.findAuthRelated(req, database: db)
                .and(inputModel.update(Output.Model(), req: req, database: db))
                .flatMap { relatedResourceMiddleware.handleRelated($0.1, relatedModel: $0.0, req: req, database: db) }
                .flatMapThrowing { try $0.0.attached(to: $0.1, with: childrenKeyPath) }
                .flatMap { $0.save(on: db).transform(to: $0) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }

    static func createAuthRelated<Input, Output, RelatedModel>(
        req: Request,
        using: Input.Type,
        relatedResourceMiddleware: RelatedResourceControllerMiddleware<Self, RelatedModel> = .defaultMiddleware,
        childrenKeyPath: ChildrenKeyPath<Self, RelatedModel>) throws -> EventLoopFuture<Output>
        where

        Input: ResourceUpdateModel,
        Output: ResourceOutputModel,
        Output.Model: Fluent.Model,
        Output.Model.IDValue: LosslessStringConvertible,
        Self == Output.Model,
        Input.Model == Output.Model,
        Output.Model: ResourceOutputModel,
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable{


        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        let keyPath = childrenKeyPath
        return req.db.tryTransaction { db in

            try Self.findAuthRelated(req, database: db)
                    .and(inputModel.update(Output.Model(), req: req, database: db))
                    .flatMap { relatedResourceMiddleware.handleRelated($0.1, relatedModel: $0.0, req: req, database: db) }
                    .flatMap { (model, related) in  model.save(on: db).transform(to: (model, related)) }
                    .flatMapThrowing { (model, related) in (try model.attached(to: related, with: keyPath), related) }
                    .flatMap { (model, related) in [related.save(on: db), model.save(on: db)]
                        .flatten(on: db.context.eventLoop)
                        .transform(to: model) }
                    .flatMapThrowing { try Output($0, req: req)}
        }
    }

    static func createAuthRelated<Input, Output, RelatedModel, Through>(
        req: Request,
        using: Input.Type,
        relatedResourceMiddleware: RelatedResourceControllerMiddleware<Self, RelatedModel> = .defaultMiddleware,
        siblingKeyPath: SiblingKeyPath<RelatedModel, Self, Through>) throws -> EventLoopFuture<Output>
        where

        Input: ResourceUpdateModel,
        Output: ResourceOutputModel,
        Output.Model: Fluent.Model,
        Through: Fluent.Model,
        Output.Model.IDValue: LosslessStringConvertible,
        Self == Output.Model,
        Input.Model == Output.Model,
        Output.Model: ResourceOutputModel,
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {

        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        return req.db.tryTransaction { db in

            try Self.findAuthRelated(req, database: db)
                .and(inputModel.update(Output.Model(), req: req, database: db))
                .flatMap { relatedResourceMiddleware.handleRelated($0.1, relatedModel: $0.0, req: req, database: db) }
                .flatMap { (model, related) in model.save(on: db).transform(to: (model, related)) }
                .flatMap { (model, related) in model.attached(to: related, with: siblingKeyPath, on: db) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
}

