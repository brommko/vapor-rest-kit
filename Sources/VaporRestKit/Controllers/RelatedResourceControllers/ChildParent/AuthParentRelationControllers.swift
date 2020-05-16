//
//  
//  
//
//  Created by Sergey Kazakov on 04.05.2020.
//

import Vapor
import Fluent

//MARK:- CreateAuthParentRelationController

struct CreateAuthParentRelationController<Model, RelatedModel, Output, EagerLoading>: CreatableRelationController, AuthParentResourceRelationProvider
    where
    Output: ResourceOutputModel,
    Model == Output.Model,
    Model.IDValue: LosslessStringConvertible,
    RelatedModel: Fluent.Model,
    RelatedModel.IDValue: LosslessStringConvertible,
    RelatedModel: Authenticatable,
    EagerLoading: EagerLoadProvider,
    EagerLoading.Model == Model {


    let relationNamePath: String
    let inversedChildrenKeyPath: ChildrenKeyPath<Model, RelatedModel>

}


//MARK:- DeleteAuthParentRelationController

struct DeleteAuthParentRelationController<Model, RelatedModel, Output, Input, EagerLoading>: DeletableRelationController, AuthParentResourceRelationProvider
    where
    Output: ResourceOutputModel,
    Model == Output.Model,
    Model.IDValue: LosslessStringConvertible,
    Input: ResourceDeleteHandler,
    Model == Input.Model,
    RelatedModel: Fluent.Model,
    RelatedModel.IDValue: LosslessStringConvertible,
    RelatedModel: Authenticatable,
    EagerLoading: EagerLoadProvider,
EagerLoading.Model == Model {

    let relationNamePath: String
    let inversedChildrenKeyPath: ChildrenKeyPath<Model, RelatedModel>

}





