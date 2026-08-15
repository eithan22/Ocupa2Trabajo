import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/contracts_provider.dart';
import '../providers/payments_provider.dart';
import 'contract_detail_screen.dart';
import 'contracts_list_screen.dart';
import 'payments_history_screen.dart';

final List<RouteBase> contractsPaymentsRoutes = [
  GoRoute(
    path: '/contracts',
    builder: (context, state) => ChangeNotifierProvider(
      create: (_) => ContractsProvider(),
      child: const ContractsListScreen(),
    ),
  ),
  GoRoute(
    path: '/contracts/:id',
    builder: (context, state) => ChangeNotifierProvider(
      create: (_) => ContractsProvider(),
      child: ContractDetailScreen(contractId: state.pathParameters['id']!),
    ),
  ),
  GoRoute(
    path: '/payments',
    builder: (context, state) => ChangeNotifierProvider(
      create: (_) => PaymentsProvider(),
      child: const PaymentsHistoryScreen(),
    ),
  ),
];
