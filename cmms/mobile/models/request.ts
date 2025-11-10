import WorkOrder from './workOrder';
import { WorkOrderBase } from './workOrderBase';
import File from './file';

export default interface Request extends WorkOrderBase {
  cancelled: boolean;
  audioDescription: File;
  workOrder: WorkOrder;
  customId: string;
}
