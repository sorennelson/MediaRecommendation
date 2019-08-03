from django.db import models
from picklefield.fields import PickledObjectField


class MLModel(models.Model):
    cfmodel = PickledObjectField()
