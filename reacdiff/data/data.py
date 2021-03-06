import h5py
import numpy as np

import reacdiff.utils as utils


class Dataset:
    """Contains time-dependent state data and associated targets."""

    def __init__(self, data, targets, data2=None):
        """
        :param data: An array of observable states.
        :param targets: An array of targets corresponding to the observable states.
        :param data2: A second array of observable states if there are two observables.
        """
        assert len(data) == len(targets)
        self.data = data
        self.targets = targets
        self.data2 = data2
        if self.data2 is not None:
            assert len(self.data2) == len(self.data)

    def shuffle(self, seed=None):
        if self.data2 is None:
            self.data, self.targets = utils.shuffle_arrays(
                self.data, self.targets, seed=seed)
        else:
            self.data, self.data2, self.targets = utils.shuffle_arrays(
                self.data, self.data2, self.targets, seed=seed)

    def save(self, name):
        save_data(self.data, name + '_states')
        save_data(self.targets, name + '_targets')
        if self.data2 is not None:
            save_data(self.data2, name + '_states2')

    def get_data(self):
        return [self.data] if self.data2 is None else [self.data, self.data2]

    def get_num_observables(self):
        return 1 if self.data2 is None else 2

    def __len__(self):
        return len(self.data)

    def __getitem__(self, item):
        if self.data2 is None:
            return Dataset(self.data[item], self.targets[item])
        else:
            return Dataset(self.data[item], self.targets[item], self.data2[item])


def load_data(path, max_read=None, key='data'):
    """
    :param path: An HDF5 file.
    :param max_read: Maximum number of samples to read.
    :param key: Data key in HDF5 file.
    :return: Numpy array of data
    """
    with h5py.File(path, 'r') as f:
        data = f[key][:] if max_read is None else f[key][:max_read]
    return data


def save_data(data, path, key='data'):
    with h5py.File(path, 'w') as f:
        f.create_dataset(key, data=data)


def split_data(data, splits=(0.9, 0.05, 0.05), seed=None):
    data.shuffle(seed=seed)
    train_split = int(splits[0] * len(data))
    train_val_split = int((splits[0] + splits[1]) * len(data))
    return data[:train_split], data[train_split:train_val_split], data[train_val_split:]
