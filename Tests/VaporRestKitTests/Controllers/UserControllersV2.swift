//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 15.08.2021.
//

import Foundation

@testable import VaporRestKit
import XCTVapor
import Vapor
import Fluent


struct UserControllersV2 {
    struct UsersController {
        func create(req: Request) throws -> User.Output {
            try ResourceController<User.Output>().create(
                req: req,
                using: User.Input.self)
        }

        func read(req: Request) throws -> User.Output {
            try ResourceController<User.Output>().read(
                req: req)
        }
    }

    struct UsersForTodoController {
        func read(req: Request) async throw -> User.Output {
            try RelatedResourceController<User.Output>().read(
                req: req,
                relationKeyPath: \Todo.$assignees)
        }

        func index(req: Request) async throw -> CursorPage<User.Output> {
            try RelatedResourceController<User.Output>().getCursorPage(
                req: req,
                relationKeyPath: \Todo.$assignees,
                config: CursorPaginationConfig.defaultConfig)
        }
    }

    struct TodoAssigneesRelationController {
        let todoOwnerGuardMiddleware = ControllerMiddleware<User, Todo>(handler: { (user, todo, req, db) in
            db.eventLoop
                .tryFuture { try req.auth.require(User.self) }
                .guard({ $0.id == todo.$user.id }, else: Abort(.unauthorized))
                .transform(to: (user, todo))
        })

        func addAssignee(req: Request) async throw -> User.Output {
            try RelationsController<User.Output>().createRelation(
                req: req,
                willAttach: todoOwnerGuardMiddleware,
                relationKeyPath: \Todo.$assignees)
        }

        func removeAssignee(req: Request) async throw -> User.Output {
            try RelationsController<User.Output>().deleteRelation(
                req: req,
                willDetach: todoOwnerGuardMiddleware,
                relationKeyPath: \Todo.$assignees)
        }
    }
}
