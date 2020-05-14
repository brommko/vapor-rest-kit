//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 28.04.2020.
//

import Vapor
import Fluent

enum IterableControllerConfig {
    case fetchAll
    case paginateWithCursor
    case paginateByPage
}

protocol IterableResourceController: ResourceControllerProtocol {
    associatedtype Output
    associatedtype Model
    
    func readWithCursorPagination(_: Request) throws -> EventLoopFuture<CursorPage<Output>>

    func readWithPagination(_: Request) throws -> EventLoopFuture<Page<Output>>

    func readAll(_: Request) throws -> EventLoopFuture<[Output]>

    var config: IterableControllerConfig { get }

    func prepareQueryBuilder(_ req: Request) throws -> EventLoopFuture<QueryBuilder<Model>>
}

extension IterableResourceController where Self: ResourceModelProviding {
    func readWithCursorPagination(_ req: Request) throws -> EventLoopFuture<CursorPage<Output>> {
        return try prepareQueryBuilder(req)
            .flatMap { $0.paginateWithCursor(for: req, config: self.paginationConfig) }
            .map { $0.map { Output($0) } }
    }

    func readWithPagination(_ req: Request) throws -> EventLoopFuture<Page<Output>> {
        return try prepareQueryBuilder(req)
            .flatMap { $0.paginate(for: req) }
            .map { $0.map { Output($0) } }
    }

    func readAll(_ req: Request) throws -> EventLoopFuture<[Output]> {
        return try prepareQueryBuilder(req)
            .flatMap { $0.all() }
            .map { $0.map { Output($0) } }
    }
}

extension IterableResourceController where Self: ResourceModelProviding {
    var config: IterableControllerConfig { return .paginateWithCursor }
    var paginationConfig: CursorPaginationConfig { return .defaultConfig }
}

extension IterableResourceController where Self: ResourceModelProviding {
    func prepareQueryBuilder(_ req: Request) throws -> EventLoopFuture<QueryBuilder<Model>> {
        let queryBuilder = try Model.query(on: req.db)
            .with(self.eagerLoadHandler, for: req)
            .sort(self.sortingHandler, for: req)
            .filter(self.filteringHandler, for: req)

        return req.eventLoop.makeSucceededFuture(queryBuilder)
    }
}

extension IterableResourceController where Self: ChildrenResourceModelProviding {
    func prepareQueryBuilder(_ req: Request) throws -> EventLoopFuture<QueryBuilder<Model>> {
        return try findRelated(req).map { $0.query(keyPath: self.childrenKeyPath, on: req.db) }
            .flatMapThrowing { try $0.with(self.eagerLoadHandler, for: req) }
            .flatMapThrowing { try $0.sort(self.sortingHandler, for: req) }
            .flatMapThrowing { try $0.filter(self.filteringHandler, for: req) }
    }
}

extension IterableResourceController where Self: ParentResourceModelProviding {
    func prepareQueryBuilder(_ req: Request) throws -> EventLoopFuture<QueryBuilder<Model>> {
        return try findRelated(req)
            .map { $0.query(keyPath: self.inversedChildrenKeyPath, on: req.db) }
            .flatMapThrowing { try $0.with(self.eagerLoadHandler, for: req) }
            .flatMapThrowing { try $0.sort(self.sortingHandler, for: req) }
            .flatMapThrowing { try $0.filter(self.filteringHandler, for: req) }
    }
}

extension IterableResourceController where Self: SiblingsResourceModelProviding {
    func prepareQueryBuilder(_ req: Request) throws -> EventLoopFuture<QueryBuilder<Model>> {
        return try findRelated(req)
            .map { $0.queryRelated(keyPath: self.siblingKeyPath, on: req.db) }
            .flatMapThrowing { try $0.with(self.eagerLoadHandler, for: req) }
            .flatMapThrowing { try $0.sort(self.sortingHandler, for: req) }
            .flatMapThrowing { try $0.filter(self.filteringHandler, for: req) }
    }
}