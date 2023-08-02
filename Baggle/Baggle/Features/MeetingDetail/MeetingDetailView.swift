//
//  MeetingDetailView.swift
//  Baggle
//
//  Created by 양수빈 on 2023/07/30.
//

import SwiftUI

import ComposableArchitecture

struct MeetingDetailView: View {

    let store: StoreOf<MeetingDetailFeature>

    @Environment(\.dismiss) private var dismiss

    var body: some View {

        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                VStack(spacing: 20) {
                    Text("모임 생성")
                        .font(.title)

                    if let data = viewStore.meetingData {
                        Text("모임명: \(data.name), 모임 id: \(data.id)")
                    }

                    HStack(spacing: 10) {
                        Button("방 폭파하기") {
                            viewStore.send(.showAlert(.delete))
                        }

                        Button("방장 넘기기") {
                            print("방장 넘기기 alert")
                        }
                    }

                    Button("뒤로가기") {
                        dismiss()
                    }
                    .buttonStyle(BagglePrimaryStyle(size: .small, shape: .round))
                }

                BaggleAlert(
                    isPresented: Binding(
                        get: { viewStore.isAlertPresented },
                        set: { _ in viewStore.send(.showAlert(.delete)) }),
                    title: viewStore.alertTitle,
                    description: viewStore.alertDescription,
                    rightButtonTitle: viewStore.alertRightButtonTitle) {
                        viewStore.send(.deleteMeeting)
                    }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onChange(of: viewStore.isDeleted) { _ in
                dismiss()
                // onReceive가 onAppear보다 먼저 실행되기 때문에
                // 딜레이 주지 않는 경우 refresh와 onappear(fetch) 둘다 실행됨
                // onReceive - refreshMeetingList 한번만 실행되도록
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
//                    postObserverAction(.refreshMeetingList)
//                }
            }
        }
    }
}

struct MeetingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingDetailView(
            store: Store(
                initialState: MeetingDetailFeature.State(
                    meetingData: MeetingDetail(
                        // swiftlint:disable:next multiline_arguments
                        id: 100, name: "모임방1000", place: "강남역",
                        // swiftlint:disable:next multiline_arguments
                        date: "2023년 4월 9일", time: "16:40", memo: "ㅇㅇ",
                        members: [Member(
                            // swiftlint:disable:next multiline_arguments
                            userid: 1, name: "콩이", profileURL: "",
                            // swiftlint:disable:next multiline_arguments
                            isOwner: true, certified: false, certImage: "")],
                        isConfirmed: false,
                        // swiftlint:disable:next multiline_arguments
                        emergencyButtonActive: false, emergencyButtonActiveTime: "")),
                reducer: MeetingDetailFeature(meetingId: 1)
            )
        )
    }
}
