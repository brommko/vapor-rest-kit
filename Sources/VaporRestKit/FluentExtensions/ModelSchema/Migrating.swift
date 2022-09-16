//
//  
//  
//
//  Created by Sergey Kazakov on 06.04.2020.
//

import Vapor
import Fluent

//MARK:- InitialMigration

public struct Migrating<T: Model> {
    public typealias MigratingClosure = (Database) -> EventLoopFuture<Void>

    public let name: String
    private let prepareClosure: MigratingClosure
    private let revertClosure: MigratingClosure

    init(name: String,
         with prepareClosure: @escaping MigratingClosure,
         revertClosure: @escaping MigratingClosure) {
        self.name = name
        self.prepareClosure = prepareClosure
        self.revertClosure = revertClosure
    }
}

extension Migrating: AsyncMigration {
    public func prepare(on database: Database) async throws {
        prepareClosure(database)
    }

    public func revert(on database: Database) async throws {
        revertClosure(database)
    }
}

public extension AsyncMigration {
    static func createInitialMigration(
        with prepare: @escaping MigratingClosure,
        revert: @escaping MigratingClosure = { db in db.schema(T.schema).delete() }) -> Migrating {

        Migrating(
            name: "InitialMigration for \(T.schema)",
            with: prepare,
            revertClosure: revert)
    }
}
