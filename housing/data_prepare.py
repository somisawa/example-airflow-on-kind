from sklearn.datasets import fetch_california_housing
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error


def data_prepare(test_sizse):
    housing = fetch_california_housing(as_frame=True)
    df = housing["data"]
    targets = housing["target"]

    X_train, X_valid, y_train, y_valid = train_test_split(
        df.values, targets, test_size=0.33, random_state=42
    )

    return X_train, X_valid, y_train, y_valid
