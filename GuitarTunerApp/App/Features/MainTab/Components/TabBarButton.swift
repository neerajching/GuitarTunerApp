//
//  TabBarButton.swift
//  GuitarTunerApp
//
//  Created by Negi on 06/08/26.
//

import SwiftUI

struct TabBarButton: View {

    let tab: MainTab

    let isSelected: Bool

    let action: () -> Void
    
    var nameSpace: Namespace.ID

    var body: some View {

        Button(action: action) {

            VStack(spacing: AppSpacing.xs) {

                TabBarIndicator(isSelected: isSelected, namespace: nameSpace)

                Image(systemName: tab.icon(selected: isSelected))
                    .font(.system(size: AppIconSize.md, weight: .medium))
                        .foregroundStyle(
                            isSelected
                            ? AppColor.TabBar.selected
                            : AppColor.TabBar.unselected
                        )

                Text(tab.title)
                .font(
                    isSelected
                    ? AppFont.primary.medium(.caption)
                    : AppFont.primary.regular(.caption)
                )
                .foregroundStyle(
                    isSelected
                    ? AppColor.TabBar.selected
                    : AppColor.Text.secondary
                )
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(
                isSelected ? 1.08 : 1
            )

            .offset(
                y: isSelected ? -2 : 0
            )

            .animation(
                AppAnimation.spring,
                value: isSelected
            )
        }
        .buttonStyle(.plain)
        
        // Accesibility
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(tab.title)
        .accessibilityHint("Switch to \(tab.title)")
        .accessibilityAddTraits(
            isSelected ? .isSelected : []
        )
        
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        
    }

    
    
}
