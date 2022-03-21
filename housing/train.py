from bldskl.train import Trainer
from sklearn.metrics import mean_squared_error, mean_absolute_error
from skl2onnx.common.data_types import FloatTensorType

metrics = [("mse", mean_squared_error), ("mae", mean_absolute_error)]


def train(data, experiment_path, result_path):
    X_train, X_valid, y_train, y_valid = data
    trainer = Trainer(experiment_path=experiment_path,
                      result_path=result_path, metrics=metrics)

    initial_type = [("float_input", FloatTensorType([None, 8]))]
    trainer.run(X_train, y_train, X_valid, y_valid,
                onnx_initial_type=initial_type)
