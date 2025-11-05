import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/party_provider.dart';
import '../../domain/entities/party_entity.dart';
import 'edit_party_page.dart';
import 'party_detail_page.dart';

class PartiesListPage extends StatefulWidget {
  const PartiesListPage({super.key});

  @override
  State<PartiesListPage> createState() => _PartiesListPageState();
}

class _PartiesListPageState extends State<PartiesListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadParties();
    });
  }

  void _loadParties() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final partyProvider = Provider.of<PartyProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    
    if (userId != null) {
      partyProvider.loadParties(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parties'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'parties_fab',
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRouter.addParty);
          if (result == true) {
            _loadParties();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text('Add Party', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Consumer<PartyProvider>(
        builder: (context, partyProvider, child) {
          if (partyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (partyProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(partyProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadParties,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final parties = partyProvider.parties;

          if (parties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    size: 64,
                    color: AppColors.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No parties yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first party to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onBackground.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadParties(),
            child: ListView.builder(
              itemCount: parties.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final party = parties[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 50)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shadowColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: _getPartyColor(party.partyType),
                      backgroundImage:
                          party.imageUrl != null ? NetworkImage(party.imageUrl!) : null,
                      child: party.imageUrl == null
                          ? Text(
                              party.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      party.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (party.phoneNumber != null) ...[
                          const SizedBox(height: 4),
                          Text('📞 ${party.phoneNumber}'),
                        ],
                        if (party.gstin != null) ...[
                          const SizedBox(height: 2),
                          Text('GSTIN: ${party.gstin}'),
                        ],
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPartyColor(party.partyType).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getPartyTypeLabel(party.partyType),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getPartyColor(party.partyType),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (party.openingBalance != 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '₹${party.openingBalance.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: party.openingBalance > 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                      onTap: () {
                        _showPartyOptions(context, party);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
        ),
      ),
    );
  }

  Color _getPartyColor(PartyType type) {
    switch (type) {
      case PartyType.customer:
        return Colors.green;
      case PartyType.vendor:
        return Colors.blue;
      case PartyType.both:
        return Colors.purple;
    }
  }

  String _getPartyTypeLabel(PartyType type) {
    switch (type) {
      case PartyType.customer:
        return 'Customer';
      case PartyType.vendor:
        return 'Vendor';
      case PartyType.both:
        return 'Both';
    }
  }

  void _showPartyOptions(BuildContext context, PartyEntity party) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info, color: AppColors.primary),
              title: const Text('View Details'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartyDetailPage(party: party),
                  ),
                );
                if (result == true) {
                  _loadParties();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Party'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPartyPage(party: party),
                  ),
                );
                if (result == true) {
                  _loadParties();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Party'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, party);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PartyEntity party) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Party'),
        content: Text('Are you sure you want to delete ${party.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final partyProvider = Provider.of<PartyProvider>(context, listen: false);
              final success = await partyProvider.deleteParty(party.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Party deleted successfully'
                        : partyProvider.errorMessage ?? 'Failed to delete party'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

