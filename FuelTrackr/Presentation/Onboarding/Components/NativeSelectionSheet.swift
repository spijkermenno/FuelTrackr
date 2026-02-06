//
//  NativeSelectionSheet.swift
//  FuelTrackr
//
//  Native iOS selection sheet with search functionality
//

import SwiftUI

public struct NativeSelectionSheet: View {
    let items: [String]
    let title: String
    let customOptionText: String
    @Binding var selectedItem: String
    @Binding var isCustomEntry: Bool
    @Binding var isPresented: Bool
    
    @State private var searchText: String = ""
    
    private var filteredItems: [String] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    public init(
        items: [String],
        title: String,
        customOptionText: String,
        selectedItem: Binding<String>,
        isCustomEntry: Binding<Bool>,
        isPresented: Binding<Bool>
    ) {
        self.items = items
        self.title = title
        self.customOptionText = customOptionText
        self._selectedItem = selectedItem
        self._isCustomEntry = isCustomEntry
        self._isPresented = isPresented
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                // List of items
                List {
                    ForEach(filteredItems, id: \.self) { item in
                        Button(action: {
                            selectedItem = item
                            isCustomEntry = false
                            isPresented = false
                        }) {
                            HStack {
                                Text(item)
                                    .foregroundColor(OnboardingColors.primaryText)
                                Spacer()
                                if selectedItem == item && !isCustomEntry {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(OnboardingColors.primaryBlue)
                                }
                            }
                        }
                    }
                    
                    // Custom entry option
                    Button(action: {
                        isCustomEntry = true
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(OnboardingColors.primaryBlue)
                            Text(customOptionText)
                                .foregroundColor(OnboardingColors.primaryBlue)
                            Spacer()
                            if isCustomEntry {
                                Image(systemName: "checkmark")
                                    .foregroundColor(OnboardingColors.primaryBlue)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("close", comment: "Close")) {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// Search bar component
private struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(OnboardingColors.secondaryText)
            
            TextField(NSLocalizedString("search", comment: "Search"), text: $text)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(OnboardingColors.secondaryText)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark 
                    ? UIColor(OnboardingColors.darkGray)
                    : UIColor(OnboardingColors.white)
            })
        )
        .cornerRadius(10)
    }
}



