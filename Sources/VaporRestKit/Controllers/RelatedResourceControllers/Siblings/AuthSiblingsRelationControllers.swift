//
//  File 2.swift
//  
//
//  Created by Sergey Kazakov on 04.05.2020.
//

import Vapor
import Fluent

//MARK:- CreateRelatedResourceController

open struct CreateAuthSiblingRelationController<Model, RelatedModel, Through, Output, Input, EagerLoading>: CreatableRelationController, AuthSiblingsResourceRelationProviding

    where
    Output: ResourceOutputModel,
    Input: ResourceUpdateModel,
    Model == Input.Model,
    Model == Output.Model,
    RelatedModel: Fluent.Model,
    Model.IDValue: LosslessStringConvertible,
    RelatedModel.IDValue: LosslessStringConvertible,
    RelatedModel: Authenticatable,
    EagerLoading: EagerLoadProvider,
    EagerLoading.Model == Model,
    Through: Fluent.Model {

    let relationNamePath: String
    let siblingKeyPath: SiblingKeyPath<RelatedModel, Model, Through>
}

//MARK:- DeleteRelatedResourceController

open struct DeleteAuthSiblingRelationController<Model, RelatedModel, Through, Output, EagerLoading>:
    DeletableRelationController, AuthSiblingsResourceRelationProviding
    where
    Output: ResourceOutputModel,
    Model == Output.Model,
    Model.IDValue: LosslessStringConvertible,
    RelatedModel: Fluent.Model,
    RelatedModel.IDValue: LosslessStringConvertible,
    RelatedModel: Authenticatable,
    EagerLoading: EagerLoadProvider,
    EagerLoading.Model == Model,
    Through: Fluent.Model {

    let relationNamePath: String
    let siblingKeyPath: SiblingKeyPath<RelatedModel, Model, Through>

}