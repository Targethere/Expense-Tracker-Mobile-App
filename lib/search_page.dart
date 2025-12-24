import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/expense_provider.dart';
import 'models/expense_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Color accentPurple = const Color(0xFF8A5BFF);
  final Color accentBlue = const Color(0xFF00A9FF);
  final Color accentGreen = const Color(0xFF00C48C);
  final Color lightBg = const Color(0xFFF9F9F9);

  final TextEditingController _searchController = TextEditingController();
  List<Expense> _searchResults = [];
  String _selectedFilter = "All";
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
      _performSearch();
    });
  }

  void _performSearch() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      _searchResults = [];
      return;
    }

    // Search in all expenses
    _searchResults = provider.expenses.where((expense) {
      final matchesQuery =
          expense.description.toLowerCase().contains(query) ||
          expense.category.toLowerCase().contains(query) ||
          (expense.notes?.toLowerCase().contains(query) ?? false);

      // Apply filter
      switch (_selectedFilter) {
        case "This Week":
          final weekAgo = DateTime.now().subtract(const Duration(days: 7));
          return matchesQuery && expense.date.isAfter(weekAgo);
        case "This Month":
          final now = DateTime.now();
          final firstDayOfMonth = DateTime(now.year, now.month, 1);
          return matchesQuery && expense.date.isAfter(firstDayOfMonth);
        case "Food & Dining":
        case "Transportation":
        case "Bills & Utilities":
        case "Shopping":
        case "Healthcare":
        case "Entertainment":
          return matchesQuery && expense.category == _selectedFilter;
        case "Over ৳500":
          return matchesQuery && expense.amount > 500;
        default:
          return matchesQuery;
      }
    }).toList();

    // Sort by date (most recent first)
    _searchResults.sort((a, b) => b.date.compareTo(a.date));
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _performSearch();
    });
  }

  BoxDecoration commonCardDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final totalExpenses = expenseProvider.expenses.length;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _searchCard(),
                const SizedBox(height: 12),
                _quickFiltersCard(),
                const SizedBox(height: 12),
                if (_isSearching) ...[
                  Row(
                    children: [
                      Text(
                        "${_searchResults.length} Result${_searchResults.length != 1 ? 's' : ''}",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (_selectedFilter != "All") ...[
                        const SizedBox(width: 6),
                        _SmallBadge(text: _selectedFilter),
                      ],
                      const Spacer(),
                      if (_selectedFilter != "All")
                        TextButton(
                          onPressed: () => _applyFilter("All"),
                          child: const Text("Clear Filter"),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (!_isSearching && totalExpenses == 0)
                  _emptyState()
                else if (!_isSearching)
                  _suggestionsCard()
                else if (_searchResults.isEmpty)
                  _noResultsState()
                else ...[
                  ..._searchResults.map((expense) => _resultItem(expense)),
                  const SizedBox(height: 8),
                  _totalCard(_searchResults),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _searchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search expenses by description, category...",
              prefixIcon: const Icon(CupertinoIcons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).canvasColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentPurple, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionsCard() {
    final suggestions = [
      "Transportation",
      "Food & Dining",
      "Bills & Utilities",
      "Shopping",
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Try searching:",
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions
                .map(
                  (s) => GestureDetector(
                    onTap: () {
                      _searchController.text = s;
                    },
                    child: _chip(s, accentBlue, const Color(0xFFE8F5FE)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _quickFiltersCard() {
    final quickFilters = [
      "All",
      "This Week",
      "This Month",
      "Food & Dining",
      "Over ৳500",
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Filters",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickFilters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return GestureDetector(
                onTap: () => _applyFilter(filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF3E8FF)
                        : Theme.of(context).cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? accentPurple
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected
                          ? accentPurple
                          : Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _resultItem(Expense expense) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: commonCardDecoration(),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: accentPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        expense.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        "•",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.3),
                        ),
                      ),
                      Text(
                        expense.paymentMethod,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        "•",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.3),
                        ),
                      ),
                      Text(
                        _formatDate(expense.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              "৳${expense.amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalCard(List<Expense> results) {
    final total = results.fold(0.0, (sum, expense) => sum + expense.amount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Amount",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  "${results.length} transaction${results.length != 1 ? 's' : ''}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "৳${total.toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFFD32F2F),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: commonCardDecoration(),
      child: Column(
        children: const [
          Icon(CupertinoIcons.doc_text, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No expenses yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Start adding expenses to search through them",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _noResultsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: commonCardDecoration(),
      child: Column(
        children: [
          const Icon(CupertinoIcons.search, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No results found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try searching with different keywords or filters",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withOpacity(0.8)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Food & Dining":
        return CupertinoIcons.cart;
      case "Transportation":
        return CupertinoIcons.car;
      case "Bills & Utilities":
        return CupertinoIcons.bolt;
      case "Shopping":
        return CupertinoIcons.bag;
      case "Healthcare":
        return CupertinoIcons.heart;
      case "Entertainment":
        return CupertinoIcons.game_controller;
      default:
        return CupertinoIcons.circle;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return "Today";
    } else if (expenseDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;
  const _SmallBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5FE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF0277BD),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
