import SwiftUI

/// Compact MonkeyType-style theme picker.
/// Segmented `Presets | Custom`. Presets tab = 2-column scrollable chip grid.
/// Custom tab = 4 color wells (Primary / Background / Surface / Text).
/// Designed to slot into a `DKCard` without blowing out vertical space —
/// chip grid is capped at ~240pt and scrolls internally.
public struct DKThemePicker: View {
    @ObservedObject private var themeManager: ThemeManager
    private let theme: Theme
    private let scheme: ColorScheme
    private let catalog: [PresetTheme]
    private let maxGridHeight: CGFloat?

    @State private var tab: Tab = .presets

    private enum Tab: Hashable { case presets, custom }

    public init(
        themeManager: ThemeManager,
        theme: Theme,
        scheme: ColorScheme,
        catalog: [PresetTheme] = PresetCatalog.all,
        maxGridHeight: CGFloat? = 260
    ) {
        self.themeManager = themeManager
        self.theme = theme
        self.scheme = scheme
        self.catalog = catalog
        self.maxGridHeight = maxGridHeight
        _tab = State(initialValue: themeManager.hasCustomOverrides ? .custom : .presets)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.m) {
            Picker("Mode", selection: $tab) {
                Text("Presets").tag(Tab.presets)
                Text("Custom").tag(Tab.custom)
            }
            .pickerStyle(.segmented)

            switch tab {
            case .presets: presetsGrid
            case .custom: customPanel
            }
        }
    }

    // MARK: - Presets

    private var presetsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: theme.spacing.s),
            GridItem(.flexible(), spacing: theme.spacing.s)
        ]

        return ScrollView {
            LazyVGrid(columns: columns, spacing: theme.spacing.s) {
                ForEach(catalog) { preset in
                    presetChip(preset)
                }
            }
            .padding(.vertical, 2)
        }
        .frame(maxHeight: maxGridHeight)
    }

    private func presetChip(_ preset: PresetTheme) -> some View {
        let isSelected = themeManager.preset.rawValue == preset.id && !themeManager.hasCustomOverrides
        let swatch = preset.swatch(for: scheme)

        return Button {
            selectPreset(preset)
        } label: {
            HStack(spacing: theme.spacing.xs) {
                swatchDots(swatch)
                Text(preset.displayName)
                    .font(theme.typography.caption.weight(.medium))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, theme.spacing.s)
            .frame(height: 38)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.radii.chip, style: .continuous)
                    .fill(theme.colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.chip, style: .continuous)
                    .strokeBorder(
                        isSelected ? theme.colors.accentPrimary : theme.colors.border,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(preset.displayName)\(isSelected ? ", selected" : "")")
    }

    private func swatchDots(_ swatch: (Color, Color, Color)) -> some View {
        HStack(spacing: 3) {
            Circle().fill(swatch.0).frame(width: 10, height: 10)
            Circle().fill(swatch.1)
                .overlay(Circle().strokeBorder(theme.colors.border, lineWidth: 0.5))
                .frame(width: 10, height: 10)
            Circle().fill(swatch.2).frame(width: 10, height: 10)
        }
    }

    private func selectPreset(_ preset: PresetTheme) {
        if let raw = ThemePreset(rawValue: preset.id) {
            themeManager.preset = raw
        }
        themeManager.resetOverrides()
        if let preferred = preset.preferredScheme {
            themeManager.mode = preferred == .dark ? .dark : .light
        }
    }

    // MARK: - Custom panel

    private var customPanel: some View {
        let base = PresetCatalog.theme(for: themeManager.preset).anchors(for: scheme)
        let overrideColors = themeManager.overrides?.colors

        let primary = Binding<Color>(
            get: { overrideColors?.accentPrimary ?? base.accent },
            set: { themeManager.setOverrideAnchor(accent: $0) }
        )
        let background = Binding<Color>(
            get: { overrideColors?.background ?? base.background },
            set: { themeManager.setOverrideAnchor(background: $0) }
        )
        let surface = Binding<Color>(
            get: { overrideColors?.surface ?? base.surface },
            set: { themeManager.setOverrideAnchor(surface: $0) }
        )
        let text = Binding<Color>(
            get: { overrideColors?.textPrimary ?? base.textPrimary },
            set: { themeManager.setOverrideAnchor(textPrimary: $0) }
        )

        return VStack(spacing: theme.spacing.s) {
            colorRow("Primary", binding: primary, isOverridden: overrideColors?.accentPrimary != nil) {
                themeManager.setOverrideAnchor(clearAccent: true)
            }
            colorRow("Background", binding: background, isOverridden: overrideColors?.background != nil) {
                themeManager.setOverrideAnchor(clearBackground: true)
            }
            colorRow("Surface", binding: surface, isOverridden: overrideColors?.surface != nil) {
                themeManager.setOverrideAnchor(clearSurface: true)
            }
            colorRow("Text", binding: text, isOverridden: overrideColors?.textPrimary != nil) {
                themeManager.setOverrideAnchor(clearTextPrimary: true)
            }

            if themeManager.hasCustomOverrides {
                Button {
                    themeManager.resetOverrides()
                } label: {
                    Text("Reset to \(PresetCatalog.theme(for: themeManager.preset).displayName)")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.accentPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func colorRow(
        _ label: String,
        binding: Binding<Color>,
        isOverridden: Bool,
        reset: @escaping () -> Void
    ) -> some View {
        HStack(spacing: theme.spacing.s) {
            ColorPicker(selection: binding, supportsOpacity: false) {
                Text(label)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
            }
            if isOverridden {
                Button(action: reset) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(theme.colors.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Reset \(label)")
            }
        }
        .padding(.vertical, 2)
    }
}
