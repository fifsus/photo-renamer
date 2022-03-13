from photo_renamer import __version__
from photo_renamer import functions as fun


def test_version() -> None:
    assert __version__ == "0.1.0"


def test_get_current_directory_name() -> None:
    path: str = "C:/filip/photo-renamer/src/photo_renamer/test_directory/test2"
    result: str = "test2"
    assert fun.get_current_directory_name(path) == result
