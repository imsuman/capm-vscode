namespace suman.db;

using {
    suman.db.master,
    suman.db.transaction
} from './datamodel';

context CDSviews {
    define view![POWorklist] as
        select from transaction.purchaseorder {
            key PO_ID                             as![PurchaseOrderId],
                PARTNER_GUID.BP_ID                as![PartnerId],
                PARTNER_GUID.COMPANY_NAME         as![CompanyName],
                GROSS_AMOUNT                      as![POGrossAmount],
                CURRENCY_CODE                     as![POCurrencyCode],
            key Items.PO_ITEM_POS                 as![ItemPosition],
                Items.PRODUCT_GUID.PRODUCT_ID     as![ProductId],
                Items.PRODUCT_GUID.DESCRIPTION    as![ProductName],
                PARTNER_GUID.ADDRESS_GUID.CITY    as![City],
                PARTNER_GUID.ADDRESS_GUID.COUNTRY as![Country],
                Items.GROSS_AMOUNT                as![GrossAmount],
                Items.NET_AMOUNT                  as![NetAmount],
                Items.TAX_AMOUNT                  as![TaxAmount],
                Items.CURRENCY_CODE               as![CurrecnyCode]
        };

    //We can expose data using select query also
    define view ProductValueHelp as
        select from master.product {
            @EndUserText.label : [{
                language : 'EN',
                text     : 'Product ID'
            }, {
                language : 'DE',
                text     : 'Prodekt ID'
            }]
            PRODUCT_ID  as![ProductId],
            @EndUserText.label : [{
                language : 'EN',
                text     : 'Product description'
            }, {
                language : 'DE',
                text     : 'Prodekt description'
            }]
            DESCRIPTION as![Description]
        };

    define view![ItemView] as
        select from transaction.poitems {
            PARENT_KEY.PARTNER_GUID.NODE_KEY as![PartnerId],
            PARENT_KEY.NODE_KEY              as![ProductId],
            CURRENCY_CODE                    as![CurrencyCode],
            GROSS_AMOUNT                     as![GrossAmount],
            NET_AMOUNT                       as![NetAmount],
            TAX_AMOUNT                       as![TaxAmount],
            PARENT_KEY.OVERALL_STATUS        as![POStatus]
        };

    //View with projection and aggregation(calculation)
    define view ProductViewSub as
        select from master.product as prod {
            PRODUCT_ID        as ![ProductId],
            texts.DESCRIPTION as ![Description],
            (
                select from transaction.poitems as a {
                    SUM(
                        a.GROSS_AMOUNT
                    ) as SUM
                }
                where
                    a.PRODUCT_GUID.NODE_KEY = prod.NODE_KEY
            )                 as PO_SUM
        };

    //Exposed Association(same as above but in different way)
    //Selection of primary records and dependent items will be exposed as association
    //One view will have primary records and and another view will have dependent records connected via association
    //View on View concept
    //mixin: means exposing the association out
    //$projection: Refering to a field from Db which I am selecting
    define view ProductView as
        select from master.product
        mixin {
            PO_ORDERS : Association[ * ] to ItemView
                            on PO_ORDERS.ProductId = $projection.ProductId
        }
        into {
            NODE_KEY                           as![ProductId],
            DESCRIPTION,
            CATEGORY                           as![Category],
            PRICE                              as![Price],
            TYPE_CODE                          as![TypeCode],
            SUPPLIER_GUID.BP_ID                as![BPId],
            SUPPLIER_GUID.COMPANY_NAME         as![CompanyName],
            SUPPLIER_GUID.ADDRESS_GUID.CITY    as![City],
            SUPPLIER_GUID.ADDRESS_GUID.COUNTRY as![Country],
            // Exposed asssociation, which means when someone read the view
            //the data  for orders won't be read by default
            //until unless someone consume the association
            PO_ORDERS
        };
    // Final Consumption view
    //Advantage: Dependending on your selectionn it will total

    define view CProductValuesView as
        select from ProductView {
            ProductId,
            Country,
            PO_ORDERS.CurrencyCode as![CurrencyCode],
            sum(
                PO_ORDERS.GrossAmount
            )                      as![POGrossAmount]
        }
        group by
            ProductId,
            Country,
            PO_ORDERS.CurrencyCode

}
