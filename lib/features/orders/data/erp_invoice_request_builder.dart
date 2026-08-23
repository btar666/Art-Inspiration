import '../../../core/network/models/erp_price_policy.dart';
import '../../checkout/data/checkout_provider.dart';
import '../../../core/network/api_exception.dart';

/// بناء جسم فاتورة مبيعات لأمان ERP — POST /sales_invoices
abstract final class ErpInvoiceRequestBuilder {
  static Map<String, dynamic> build({
    required CheckoutDraft draft,
    required ErpPricePolicy pricePolicy,
    int? partyId,
  }) {
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final address = draft.selectedAddress?.fullAddress ?? '';
    final deliveryNote = draft.deliveryMethod == CheckoutDeliveryMethod.pickupAtCompany
        ? CheckoutDeliveryMethod.pickupAtCompany.label
        : null;

    final notes = [
      if (draft.customerName.trim().isNotEmpty) 'الزبون: ${draft.customerName}',
      if (draft.phone.trim().isNotEmpty) 'هاتف: ${draft.phone}',
      if (draft.secondPhone.trim().isNotEmpty)
        'هاتف بديل: ${draft.secondPhone}',
      if (deliveryNote != null) 'طريقة الاستلام: $deliveryNote',
      if (address.isNotEmpty) 'عنوان: $address',
    ].join(' | ');

    final items = draft.items
        .map((item) {
          final productId = int.tryParse(item.product.id);
          return {
            'product_id': productId,
            'name': item.product.name,
            'quantity': item.quantity,
            'unit_price': item.product.price,
            'discount': 0,
            'tax': 0,
          };
        })
        .where((item) => item['product_id'] != null)
        .toList();

    if (items.isEmpty) {
      throw const ApiException(message: 'لا توجد منتجات صالحة في الطلب');
    }

    return {
      if (partyId != null) 'party_id': partyId,
      'date': date,
      'price_policy': pricePolicy.erpValue,
      'discount': 0,
      'tax': 0,
      'paid_amount': 0,
      'notes': notes,
      'items': items,
    };
  }
}
