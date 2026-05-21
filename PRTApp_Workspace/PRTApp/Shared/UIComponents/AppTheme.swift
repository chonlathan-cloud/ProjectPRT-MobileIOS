//
//  AppTheme.swift
//  PRTApp_Workspace
//

import SwiftUI

enum AppTheme {
    enum Colors {
        static let corporateBlue = Color(red: 0.05, green: 0.13, blue: 0.28)
        static let corporateBlueSoft = Color(red: 0.10, green: 0.20, blue: 0.38)
        static let emerald = Color(red: 0.00, green: 0.52, blue: 0.34)
        static let rose = Color(red: 0.78, green: 0.11, blue: 0.24)
        static let warning = Color(red: 0.86, green: 0.48, blue: 0.08)
        static let pageBackground = Color(.systemGroupedBackground)
        static let cardStroke = Color.black.opacity(0.06)
        static let elevatedShadow = Color.black.opacity(0.08)
    }

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 18
    }

    enum Spacing {
        static let screenHorizontal: CGFloat = 20
        static let section: CGFloat = 24
        static let card: CGFloat = 16
    }

    enum Typography {
        static let sectionTitle = Font.headline.weight(.semibold)
        static let metricTitle = Font.subheadline.weight(.medium)
        static let caption = Font.caption.weight(.medium)
        static let executiveNumber = Font.system(.title3, design: .rounded).weight(.semibold)
    }
}

struct PremiumCardModifier: ViewModifier {
    var material: Material = .regularMaterial
    var cornerRadius: CGFloat = AppTheme.Radius.medium

    func body(content: Content) -> some View {
        content
            .background(material)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.Colors.cardStroke, lineWidth: 1)
            }
            .shadow(color: AppTheme.Colors.elevatedShadow, radius: 16, x: 0, y: 8)
    }
}

struct GlassPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.Radius.medium

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.34), lineWidth: 1)
            }
    }
}

extension View {
    func premiumCard(
        material: Material = .regularMaterial,
        cornerRadius: CGFloat = AppTheme.Radius.medium
    ) -> some View {
        modifier(PremiumCardModifier(material: material, cornerRadius: cornerRadius))
    }

    func glassPanel(cornerRadius: CGFloat = AppTheme.Radius.medium) -> some View {
        modifier(GlassPanelModifier(cornerRadius: cornerRadius))
    }

    func appScreenBackground() -> some View {
        background(AppTheme.Colors.pageBackground)
    }
}
