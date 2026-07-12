import 'dart:convert';

import '../../auth/data/models/auth_models.dart';
import '../../checkout/data/checkout_provider.dart';

/// بناء جسم طلب إنشاء فاتورة مبيعات حسب مواصفات Dan ERP
abstract final class ErpInvoiceRequestBuilder {
  static Map<String, dynamic> build({
    required CheckoutDraft draft,
    required AuthUser? user,
  }) {
    final now = DateTime.now();
    final issueDate = _date(now);
    final dueDate = _date(now.add(const Duration(days: 30)));
    final elementNumber = _elementNumber(now);
    final customerId = int.tryParse(user?.id ?? '') ?? 0;
    final address = draft.selectedAddress?.fullAddress ?? '';
    final customerName = draft.customerName.trim().isNotEmpty
        ? draft.customerName.trim()
        : (user?.name ?? 'عميل');
    final phone = draft.phone.trim().isNotEmpty
        ? draft.phone.trim()
        : (user?.phone ?? '');
    final email = user?.email ?? '';

    final items = <Map<String, dynamic>>[];
    for (var i = 0; i < draft.items.length; i++) {
      final item = draft.items[i];
      final product = item.product;
      final productId = int.tryParse(product.id) ?? 0;
      final lineTotal = item.lineTotal;

      items.add({
        'productId': productId,
        'productName': product.name,
        'description': product.description,
        'quantity': item.quantity,
        'unit': 1,
        'unitPrice': product.price,
        'discount': 0,
        'discountType': 'percentage',
        'taxRate': 0,
        'total': lineTotal,
        'unitList': [
          {'unitName': 'piece', 'value': 1},
        ],
        'originalUnitPrice': product.price,
        'unitName': 'piece',
        'warehouses': 'main',
        'lineId': 'line-${i + 1}',
      });
    }

    final customer = {
      'id': customerId,
      'name': customerName,
      'nameAr': customerName,
      'email': email,
      'phone': phone,
      'address': address,
      'addressAr': address,
      'taxNumber': '',
    };

    final main = {
      'elementNumber': elementNumber,
      'customerId': customerId,
      'customer': customer,
      'salesRepId': customerId == 0 ? 1 : customerId,
      'salesRep': {
        'id': customerId == 0 ? 1 : customerId,
        'name': customerName,
      },
      'paymentTermId': 1,
      'transactionId': 'TRX-${elementNumber.replaceFirst('INV-', '')}',
      'paymentTerm': null,
      'issueDate': issueDate,
      'dueDate': dueDate,
      'items': items,
      'notes': draft.secondPhone.isEmpty
          ? ''
          : 'هاتف بديل: ${draft.secondPhone}',
      'discountType': 'percentage',
      'discountValue': 0,
      'shippingCost': 0,
      'shippingAddress': address,
      'shippingAddressAr': address,
      'shippingMethod': 'Standard Delivery',
      'depositAmount': 0,
      'paidAmount': 0,
      'returnAmount': 0,
      'depositPaid': false,
      'attachments': <dynamic>[],
      'amount': {
        'subtotal': draft.subtotal,
        'total': draft.subtotal,
      },
      'currency': {
        'code': 'IQD',
        'symbol': 'IQD',
      },
      'paymentMethod': 'Cash',
      'status': 'Unpaid',
      'warehouseId': 1,
      'priceListId': '',
      'priceListName': 'Default',
      'revenueAccountId': '',
      'costCenterId': '',
      'creativePriceType': '',
      'treasuryBankAccountId': '',
    };

    final userPayload = {
      'id': customerId == 0 ? 1 : customerId,
      'name': customerName,
      'email': email,
    };

    return {
      'tableName': 'sales_invoices',
      'warehouseId': 1,
      'issueDate': issueDate,
      'dueDate': dueDate,
      'paymentMethod': 'Cash',
      'totalAmount': draft.subtotal,
      'status': 'Unpaid',
      'stockStatus': 'stockPending',
      'isDraft': false,
      'user': jsonEncode(userPayload),
      'serverImages': '[]',
      'elementNumber': elementNumber,
      'main': jsonEncode(main),
    };
  }

  static String _date(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _elementNumber(DateTime value) {
    final yy = (value.year % 100).toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');
    final dd = value.day.toString().padLeft(2, '0');
    final seq = value.millisecondsSinceEpoch.toString().substring(7);
    return 'INV-$yy$mm$dd-$seq';
  }
}
