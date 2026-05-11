// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';

// import '../../../../core/theme/app_colors.dart';
// import '../../../expenses/presentation/providers/date_filter_provider.dart';

// class DateFilterSection
//     extends ConsumerWidget {
//   const DateFilterSection({
//     super.key,
//   });

//   @override
//   Widget build(
//     BuildContext context,
//     WidgetRef ref,
//   ) {
//     final selectedDate = ref.watch(
//       selectedDateFilterProvider,
//     );

//     return Row(
//       children: [
//         Expanded(
//           child: GestureDetector(
//             onTap: () async {
//               final pickedDate =
//                   await showDatePicker(
//                 context: context,
//                 firstDate:
//                     DateTime(2020),
//                 lastDate:
//                     DateTime.now(),
//                 initialDate:
//                     selectedDate ??
//                         DateTime.now(),
//               );

//               if (pickedDate != null) {
//                 ref
//                     .read(
//                       selectedDateFilterProvider
//                           .notifier,
//                     )
//                     .state = pickedDate;
//               }
//             },
//             child: Container(
//               padding:
//                   const EdgeInsets.symmetric(
//                 horizontal: 18,
//                 vertical: 14,
//               ),
//               decoration:
//                   BoxDecoration(
//                 color: Colors.white,
//                 borderRadius:
//                     BorderRadius.circular(
//                   18,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.calendar_month,
//                     color:
//                         AppColors.primary,
//                   ),

//                   const SizedBox(
//                     width: 12,
//                   ),

//                   Expanded(
//                     child: Text(
//                       selectedDate ==
//                               null
//                           ? 'Filter by Date'
//                           : DateFormat(
//                               'dd MMM yyyy',
//                             ).format(
//                               selectedDate,
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         if (selectedDate != null) ...[
//           const SizedBox(width: 12),

//           GestureDetector(
//             onTap: () {
//               ref
//                   .read(
//                     selectedDateFilterProvider
//                         .notifier,
//                   )
//                   .state = null;
//             },
//             child: Container(
//               padding:
//                   const EdgeInsets.all(
//                 14,
//               ),
//               decoration:
//                   BoxDecoration(
//                 color: Colors.red,
//                 borderRadius:
//                     BorderRadius.circular(
//                   16,
//                 ),
//               ),
//               child: const Icon(
//                 Icons.close,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }
// }