import os
import tempfile
import json
import pytest
import src.pyrm.utils.meta


def test_read_good():
    fd, test_path = tempfile.mkstemp()
    test_dict = {"hello": "world!"}

    with os.fdopen(fd, "w") as tmp:
        json.dump(test_dict, tmp)

    assert test_dict == src.pyrm.utils.meta.read_json(test_path)
    os.remove(test_path)


def test_read_bad():
    fd, test_path = tempfile.mkstemp()
    test = [{"foo": "bar"}]

    with os.fdopen(fd, "w") as tmp:
        json.dump(test, tmp)

    with pytest.raises(TypeError) as excinfo:
        src.pyrm.utils.meta.read_json(test_path)

    assert excinfo.type is TypeError

    os.remove(test_path)
