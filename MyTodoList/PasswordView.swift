//
//  PasswordView.swift
//  MyTodoList
//
//  Created by miles on 2026/1/31.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct PasswordView: View {
    @Environment(\.dismiss) private var dismiss

    let correctPassword = "1109"
    let onSuccess: () -> Void
    let onFailure: () -> Void

    @State private var enteredPassword = ""
    @State private var showError = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // 锁图标
                Image(systemName: "lock.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)

                Text("输入密码")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)

                // 密码点显示
                HStack(spacing: 20) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index < enteredPassword.count ? Color.white : Color.gray.opacity(0.3))
                            .frame(width: 16, height: 16)
                    }
                }
                .padding(.bottom, 10)

                if showError {
                    Text("密码错误")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }

                // 数字键盘
                VStack(spacing: 20) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 30) {
                            ForEach(1...3, id: \.self) { col in
                                let number = row * 3 + col
                                numberButton(number)
                            }
                        }
                    }

                    HStack(spacing: 30) {
                        // 空白占位
                        Color.clear
                            .frame(width: 75, height: 75)

                        numberButton(0)

                        // 删除按钮
                        Button {
                            if !enteredPassword.isEmpty {
                                enteredPassword.removeLast()
                                showError = false
                            }
                        } label: {
                            Image(systemName: "delete.left")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 75, height: 75)
                        }
                    }
                }

                Spacer()

                // 取消按钮
                Button {
                    onFailure()
                } label: {
                    Text("取消")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func numberButton(_ number: Int) -> some View {
        Button {
            if enteredPassword.count < 4 {
                enteredPassword += "\(number)"
                showError = false

                if enteredPassword.count == 4 {
                    checkPassword()
                }
            }
        } label: {
            Text("\(number)")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 75, height: 75)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )
        }
    }

    private func checkPassword() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if enteredPassword == correctPassword {
                onSuccess()
            } else {
                showError = true
                enteredPassword = ""

                // 震动反馈
                #if canImport(UIKit)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                #endif
            }
        }
    }
}

#Preview {
    PasswordView(onSuccess: {}, onFailure: {})
}
