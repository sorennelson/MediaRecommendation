from ts.torch_handler.base_handler import BaseHandler
import torch
import nvtabular as nvt


class MediaHandler(BaseHandler):

    def __init__(self, workflow_path):
        super().__init__()
        self.workflow = nvt.Workflow.load(workflow_path)

    def inference(self, data, *args, **kwargs):
        """
        The Inference Function is used to make a prediction call on the given input request.
        Args:
            data (Torch Tensor): A Torch Tensor is passed to make the Inference Request.
            The shape should match the model input shape.
        Returns:
            Torch Tensor : The Predicted Torch Tensor is returned in this function.
        """
        # print(self.model.code)
        with torch.no_grad():
            results = self.model(*data, *args, **kwargs)
        # Batch size needs to stay the same for input/output so reshape to (1,mediaIds)
        results = results.view(1,results.shape[0])
        return results