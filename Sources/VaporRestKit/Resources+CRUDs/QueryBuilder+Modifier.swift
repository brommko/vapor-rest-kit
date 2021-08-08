//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18.07.2021.
//

import Vapor
import Fluent

typealias QueryModifier<Model: Fluent.Model> = (QueryBuilder<Model>) -> QueryBuilder<Model>

extension QueryBuilder {
    func with(_ queryModifier: QueryModifier<Model>?, for req: Request) -> QueryBuilder<Model> {
        guard let queryModifier = queryModifier else {
            return self
        }

        return queryModifier(self)
    }

    func using<EagerLoading: EagerLoadProvider,
               Sorting: SortProvider,
               Filtering: FilterProvider> (_ eagerLoadProvider: EagerLoading,
                                           sortProvider: Sorting,
                                           filterProvider: Filtering,
                                           for req: Request) throws -> QueryBuilder<Model> where EagerLoading.Model == Model,
                                                                                                 Sorting.Model == Model,
                                                                                                Filtering.Model == Model {

        try self.with(eagerLoadProvider, for: req)
                .sort(sortProvider, for: req)
                .filter(filterProvider, for: req)
    }


}