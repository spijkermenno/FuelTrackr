import SwiftUI

struct MonthlySummaryCard: View {
    let monthTitle: String
    let distance: String
    let fuelUsed: String
    let cost: String
    let onDetailsTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label {
                    Text(monthTitle)
                        .font(.headline)
                        .foregroundColor(Theme.colors.onBackground)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(Theme.colors.onBackground.opacity(0.7))
                }

                Spacer()

                Button(action: onDetailsTapped) {
                    Text(NSLocalizedString("details", comment: "Details"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Theme.colors.onPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.colors.primary)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 12) {
                RecapMetric(
                    icon: "car.fill",
                    iconColor: .blue,
                    value: distance,
                    label: NSLocalizedString("km_driven", comment: "Distance")
                )
                RecapMetric(
                    icon: "fuelpump.fill",
                    iconColor: .orange,
                    value: fuelUsed,
                    label: NSLocalizedString("total_fuel_used", comment: "Fuel used")
                )
                RecapMetric(
                    icon: "eurosign.circle.fill",
                    iconColor: .green,
                    value: cost,
                    label: NSLocalizedString("total_fuel_cost", comment: "Cost")
                )
            }
        }
        .padding(20)
        .background(Theme.colors.surface)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct RecapMetric: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(iconColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.system(size: 22, weight: .semibold))
                )

            Text(value)
                .font(.headline)
                .foregroundColor(Theme.colors.onBackground)

            Text(label)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 160)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    MonthlySummaryCard(
        monthTitle: "April 2025",
        distance: "500 km",
        fuelUsed: "65.13 L",
        cost: "€113,02",
        onDetailsTapped: { print("Tapped!") }
    )
    .padding()
    .previewLayout(.sizeThatFits)
    .background(Theme.colors.background)
}
