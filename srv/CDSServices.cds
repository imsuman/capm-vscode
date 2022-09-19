using {suman.db.CDSviews} from '../db/CDSviews';
using {
    suman.db.master,
    suman.db.transaction
} from '../db/datamodel';


service CDSService @(path : '/CDSServices') {

    //We can expose data like a CDS view
    entity POWorklist         as projection on CDSviews.POWorklist;
    entity ProductOrders      as projection on CDSviews.ProductViewSub;
    entity ProductAggregation as projection on CDSviews.CProductValuesView;
}
