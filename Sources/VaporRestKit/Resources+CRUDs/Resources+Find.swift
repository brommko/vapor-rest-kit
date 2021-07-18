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
                            database: Database,
                            using queryModifier: QueryModifier<Self>? = nil) throws -> EventLoopFuture<Self> {
        try Self.query(on: database)
                .with(queryModifier, for: req)
                .findBy(idKey, from: req)
    }
}


//Parent - Children

extension Authenticatable where Self: Model {
    static func findAsAuth(_ req: Request,
                           database: Database) throws -> EventLoopFuture<Self>  {

        let related = try req.auth.require(Self.self)
        return req.eventLoop.makeSucceededFuture(related)
    }
}

extension Model where IDValue: LosslessStringConvertible {
    static func findRelatedWithRootId<RelatedModel>(_ req: Request, database: Database) throws -> EventLoopFuture<RelatedModel>
        where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        return try RelatedModel
            .query(on: database)
            .findBy(RelatedModel.idKey, from: req)

    }

    static func findWithRelatedOn<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<RelatedModel, Self>,
        using queryModifier: QueryModifier<Self>?) throws -> EventLoopFuture<(Self, RelatedModel)>

        where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        try RelatedModel
            .query(on: database)
            .findBy(RelatedModel.idKey, from: req)
            .flatMapThrowing { relatedResource in
                try relatedResource
                    .query(keyPath: childrenKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .findBy(idKey, from: req)
                    .map { ($0, relatedResource) }}
            .flatMap { $0 }
    }


    static func findAuthRelated<RelatedModel: Fluent.Model>(_ req: Request,
                                                     database: Database) throws -> EventLoopFuture<RelatedModel> where RelatedModel: Authenticatable {



        let related = try req.auth.require(RelatedModel.self)
        return req.eventLoop.makeSucceededFuture(related)
    }
    

    static func findWitAuthRelatedOn<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<RelatedModel, Self>,
        using queryModifier: QueryModifier<Self>?) throws -> EventLoopFuture<(Self, RelatedModel)>

        where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {

        let related = try req.auth.require(RelatedModel.self)
        return req.eventLoop.makeSucceededFuture(related)
            .flatMapThrowing { relatedResource in
                try relatedResource
                    .query(keyPath: childrenKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .findBy(idKey, from: req)
                    .map { ($0, relatedResource) }}
            .flatMap { $0 }
    }
}


//Child- Parent

extension Model where IDValue: LosslessStringConvertible {
    static func findWithRelatedOn<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<Self, RelatedModel>,
        using queryModifier: QueryModifier<Self>?) throws -> EventLoopFuture<(RelatedModel, Self)>

        where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        try RelatedModel
            .query(on: database)
            .findBy(RelatedModel.idKey, from: req)
            .flatMapThrowing { relatedResource in
                try relatedResource
                    .query(keyPath: childrenKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .findBy(idKey, from: req)
                    .map { (relatedResource, $0) }}
            .flatMap { $0 }
    }

    static func findWithAuthRelatedOn<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<Self, RelatedModel>,
        using queryModifier: QueryModifier<Self>?) throws -> EventLoopFuture<(RelatedModel, Self)>

        where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {

        let related = try req.auth.require(RelatedModel.self)
        return req.eventLoop.makeSucceededFuture(related)
            .flatMapThrowing { relatedResource in
                try relatedResource
                    .query(keyPath: childrenKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .findBy(idKey, from: req)
                    .map { (relatedResource, $0) }}
            .flatMap { $0 }
    }
}


//Siblings

extension Model where IDValue: LosslessStringConvertible {
    static func findWithRelatedOn<RelatedModel, Through>(
        _ req: Request,
        database: Database,
        siblingKeyPath: SiblingKeyPath<RelatedModel, Self, Through>,
        using queryModifier: QueryModifier<Self>?) throws -> EventLoopFuture<(Self, RelatedModel)>

        where Through: Fluent.Model,
              RelatedModel.IDValue: LosslessStringConvertible {

        try RelatedModel
            .query(on: database)
            .findBy(RelatedModel.idKey, from: req)
            .flatMapThrowing { relatedResoure in
                try relatedResoure.queryRelated(keyPath: siblingKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .findBy(self.idKey, from: req)
                    .map { ($0, relatedResoure) }}
            .flatMap { $0 }
    }

    static func findWithAuthRelatedOn<RelatedModel, Through>(
        _ req: Request,
        database: Database,
        siblingKeyPath: SiblingKeyPath<RelatedModel, Self, Through>,
        using queryModifier: QueryModifier<Self>?) throws -> EventLoopFuture<(Self, RelatedModel)>

        where Through: Fluent.Model,
              RelatedModel.IDValue: LosslessStringConvertible,
              RelatedModel: Authenticatable {

        let related = try req.auth.require(RelatedModel.self)
        return req.eventLoop.makeSucceededFuture(related)
            .flatMapThrowing { relatedResoure in
                try relatedResoure.queryRelated(keyPath: siblingKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .findBy(self.idKey, from: req)
                    .map { ($0, relatedResoure) }}
            .flatMap { $0 }
    }
}