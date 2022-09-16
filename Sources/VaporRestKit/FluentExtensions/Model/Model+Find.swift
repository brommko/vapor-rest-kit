//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18.07.2021.
//

import Vapor
import Fluent

extension Model where IDValue: LosslessStringConvertible {
    static func findByIdKey(_ req: Request,
                            database: Database) async throws -> Self {
        try await findByIdKey(
            req,
            database: database,
            queryModifier: .empty)
    }

    static func findByIdKey(_ req: Request,
                            database: Database,
                            queryModifier: QueryModifier<Self>) async throws -> Self {
        try await Self.query(on: database)
            .with(queryModifier, for: req)
            .find(by: idKey, from: req)
    }
}

extension Model where Self: Authenticatable {
    static func requireAuth(_ req: Request,
                            database: Database) throws -> Self  {

        let related = try req.auth.require(Self.self)
        return related
    }
}

//Parent - Children

extension Model where IDValue: LosslessStringConvertible {
    static func findByIdKeys<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<RelatedModel, Self>,
        queryModifier: QueryModifier<Self>) async throws -> (Self, RelatedModel)

    where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        var related = try RelatedModel
            .query(on: database)
            .find(by: RelatedModel.idKey, from: req)
            
            try await related
                .queryRelated(keyPath: childrenKeyPath, on: database)
                .with(queryModifier, for: req)
                .find(by: idKey, from: req)
                .and(value: related)
    }

    static func findByIdKeyAndAuthRelated<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<RelatedModel, Self>,
        queryModifier: QueryModifier<Self>) throws -> EventLoopFuture<(Self, RelatedModel)>

    where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {

        let related = try req.auth.require(RelatedModel.self)
        return req.eventLoop
            .makeSucceededFuture(related)
            .flatMapThrowing { related in
                try related
                    .queryRelated(keyPath: childrenKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .find(by: idKey, from: req)
                    .and(value: related)
            }
            .flatMap { $0 }
    }
}


//Child- Parent

extension Model where IDValue: LosslessStringConvertible {

    static func findByIdKeys<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<Self, RelatedModel>,
        queryModifier: QueryModifier<Self>) throws -> EventLoopFuture<(Self, RelatedModel)>

    where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        try RelatedModel
            .query(on: database)
            .find(by: RelatedModel.idKey, from: req)
            .flatMapThrowing { related in
                try related
                    .queryRelated(keyPath: childrenKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .find(by: idKey, from: req)
                    .and(value: related)
            }
            .flatMap { $0 }
    }

    static func findByIdKeyAndAuthRelated<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<Self, RelatedModel>,
        queryModifier: QueryModifier<Self>) throws -> EventLoopFuture<(Self, RelatedModel)>

    where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {

        let related = try req.auth.require(RelatedModel.self)
        return req.eventLoop
            .makeSucceededFuture(related)
            .flatMapThrowing { related in
                try related
                    .queryRelated(keyPath: childrenKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .find(by: idKey, from: req)
                    .and(value: related)
            }
            .flatMap { $0 }
    }
}


//Siblings

extension Model where IDValue: LosslessStringConvertible {
    static func findByIdKeys<RelatedModel, Through>(
        _ req: Request,
        database: Database,
        siblingKeyPath: SiblingKeyPath<RelatedModel, Self, Through>,
        queryModifier: QueryModifier<Self>) throws -> EventLoopFuture<(Self, RelatedModel)>

    where
        Through: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        try RelatedModel
            .query(on: database)
            .find(by: RelatedModel.idKey, from: req)
            .flatMapThrowing { related in
                try related.queryRelated(keyPath: siblingKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .find(by: idKey, from: req)
                    .and(value: related)
            }
            .flatMap { $0 }
    }

    static func findByIdKeyAndAuthRelated<RelatedModel, Through>(
        _ req: Request,
        database: Database,
        siblingKeyPath: SiblingKeyPath<RelatedModel, Self, Through>,
        queryModifier: QueryModifier<Self>) throws -> EventLoopFuture<(Self, RelatedModel)>

    where
        Through: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {

        let related = try req.auth.require(RelatedModel.self)
        return req.eventLoop
            .makeSucceededFuture(related)
            .flatMapThrowing { related in
                try related.queryRelated(keyPath: siblingKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .find(by: idKey, from: req)
                    .and(value: related)
            }
            .flatMap { $0 }
    }
}
