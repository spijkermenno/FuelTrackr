//
//  SearchableDropdown.swift
//  FuelTrackr
//
//  Searchable dropdown component for vehicle brand/model selection
//

import SwiftUI

public struct SearchableDropdown: View {
    let items: [String]
    let placeholder: String
    let customOptionText: String
    @Binding var selectedItem: String
    @Binding var isCustomEntry: Bool
    
    @State private var searchText: String = ""
    @State private var isExpanded: Bool = false
    @FocusState private var isSearchFocused: Bool
    
    
    private var filteredItems: [String] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    public init(
        items: [String],
        placeholder: String,
        customOptionText: String,
        selectedItem: Binding<String>,
        isCustomEntry: Binding<Bool>
    ) {
        self.items = items
        self.placeholder = placeholder
        self.customOptionText = customOptionText
        self._selectedItem = selectedItem
        self._isCustomEntry = isCustomEntry
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Search/Input Field
            HStack {
                TextField(placeholder, text: $searchText)
                    .font(.system(size: 17, weight: .regular))
                    .focused($isSearchFocused)
                    .onChange(of: searchText) { newValue in
                        // Always update selectedItem as user types
                        selectedItem = newValue
                        // If in custom mode, don't show dropdown
                        if isCustomEntry {
                            isExpanded = false
                        }
                    }
                    .onChange(of: isSearchFocused) { focused in
                        // Only show dropdown if not in custom mode
                        if !isCustomEntry {
                            isExpanded = focused
                        } else {
                            isExpanded = false
                        }
                        
                        if !focused && !isCustomEntry {
                            // When losing focus, if searchText doesn't match any item, mark as custom
                            if !searchText.isEmpty && !filteredItems.contains(searchText) && !items.contains(searchText) {
                                isCustomEntry = true
                                selectedItem = searchText
                            }
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        selectedItem = ""
                        isCustomEntry = false
                        isSearchFocused = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(OnboardingColors.secondaryText)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding()
            .background(Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark 
                    ? UIColor(OnboardingColors.darkGray)
                    : UIColor(OnboardingColors.white)
            }))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isCustomEntry || isSearchFocused 
                            ? OnboardingColors.primaryBlue 
                            : OnboardingColors.primaryBlue.opacity(0.3), 
                        lineWidth: isCustomEntry || isSearchFocused ? 2 : 1
                    )
            )
            
            // Dropdown List
            if isExpanded {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Filtered items (only show if there are matches or search is empty)
                        if searchText.isEmpty || !filteredItems.isEmpty {
                            ForEach(filteredItems.prefix(10), id: \.self) { item in
                                Button(action: {
                                    selectedItem = item
                                    searchText = item
                                    isCustomEntry = false
                                    isSearchFocused = false
                                }) {
                                    HStack {
                                        Text(item)
                                            .font(.system(size: 17, weight: .regular))
                                            .foregroundColor(OnboardingColors.primaryText)
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .contentShape(Rectangle())
                                    .background(
                                        selectedItem == item && !isCustomEntry
                                            ? OnboardingColors.primaryBlue.opacity(0.1)
                                            : Color.clear
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(maxWidth: .infinity)
                                
                                if item != filteredItems.prefix(10).last {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                        
                        // Custom entry option (always show)
                        if !filteredItems.isEmpty || searchText.isEmpty {
                            Divider()
                                .padding(.vertical, 4)
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isCustomEntry = true
                                isExpanded = false
                                // Keep focus on the text field for immediate typing
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isSearchFocused = true
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(OnboardingColors.primaryBlue)
                                Text(customOptionText)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(OnboardingColors.primaryBlue)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                            .background(
                                isCustomEntry
                                    ? OnboardingColors.primaryBlue.opacity(0.1)
                                    : Color.clear
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxHeight: 300)
                .background(Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark 
                        ? UIColor(OnboardingColors.darkGray)
                        : UIColor(OnboardingColors.white)
                }))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(OnboardingColors.primaryBlue.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                .padding(.top, 4)
            }
        }
        .onAppear {
            if !selectedItem.isEmpty && !isCustomEntry {
                searchText = selectedItem
            } else if isCustomEntry {
                searchText = selectedItem
            }
        }
    }
}
