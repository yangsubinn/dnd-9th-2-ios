//
//  MeetingDetailFeature.swift
//  Baggle
//
//  Created by 양수빈 on 2023/07/30.
//

import ComposableArchitecture

enum MeetingDetailState {
    case empty
    case updatedData(MeetingDetail)
}

struct MeetingDetailFeature: ReducerProtocol {

    struct State: Equatable {
        // MARK: - Scope State

        var meetingId: Int
        var meetingData: MeetingDetail?
        var dismiss: Bool = false

        // Alert
        var alertType: MeetingDeleteType = .delete
        var isAlertPresented: Bool = false
        var alertTitle: String = ""
        var alertDescription: String?
        var alertRightButtonTitle: String = ""

        // delete
        @PresentationState var selectOwner: SelectOwnerFeature.State?
        var nextOwnerId: Int?
    }

    enum Action: Equatable {
        // MARK: - Scope Action

        case onAppear
        case updateData(MeetingDetail)
        case presentAlert
        case deleteMeeting

        // button
        case deleteButtonTapped
        case leaveButtonTapped
        case backButtonTapped

        case selectOwner(PresentationAction<SelectOwnerFeature.Action>)

        // delegate
        case delegate(Delegate)

        enum Delegate: Equatable {
            case deleteSuccess
            case onDisappear
        }
    }

    @Dependency(\.meetingDetailService) var meetingService

    var body: some ReducerProtocolOf<Self> {

        // MARK: - Scope

        // MARK: - Reduce

        Reduce { state, action in

            switch action {
            case .onAppear:
                let id = state.meetingId
                return .run { send in
                    if let data = await meetingService.fetchMeetingDetail(id) {
                        await send(.updateData(data))
                    }
                }

            case .updateData(let data):
                state.meetingData = data
                return .none

            case .presentAlert:
                state.alertTitle = (state.meetingData?.name ?? "-") + state.alertType.title
                state.alertDescription = state.alertType.description
                state.alertRightButtonTitle = state.alertType.rightButtonTitle
                state.isAlertPresented.toggle()
                return .none

            case .deleteMeeting:
                return .run { send in
                    // 삭제 서버 통신에 따라 분기처리
                    await send(.delegate(.deleteSuccess))
                }

            case .deleteButtonTapped:
                state.alertType = .delete
                return .run { send in
                    await send(.presentAlert)
                }

            case .leaveButtonTapped:
                state.alertType = .leave
                state.selectOwner = SelectOwnerFeature.State(
                    memberList: state.meetingData?.members ?? [])
                return .none

            case .backButtonTapped:
                state.dismiss = true
                return .none

            case .selectOwner(.presented(.leaveButtonTapped)):
                if let nextOwnerId = state.selectOwner?.selectedMemberId {
                    state.nextOwnerId = nextOwnerId
                }
                return .run { send in
                    await send(.presentAlert)
                }

            case .selectOwner:
                return .none

            case .delegate(let action):
                switch action {
                case .deleteSuccess:
                    state.isAlertPresented = false
                    state.dismiss = true
                    return .none
                case .onDisappear:
                    return .none
                }
            }
        }
        .ifLet(\.$selectOwner, action: /Action.selectOwner) {
            SelectOwnerFeature()
        }
    }
}
