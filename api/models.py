from django.contrib.postgres.fields import ArrayField
from django.db import models
from django.db.models.fields.related import ForeignKey

class Dataset(models.Model):
    name = models.CharField(max_length=50)


class Station(models.Model):
    dataset = ForeignKey(Dataset, on_delete=models.CASCADE)
    name = models.CharField(max_length=50)


class Pollutant(models.Model):
    name = models.CharField(max_length=50)
    dataset = ForeignKey(Dataset, on_delete=models.CASCADE, null=True, blank=True)


class AnnualWindow(models.Model):
    pollutant = ForeignKey(Pollutant, on_delete=models.CASCADE)
    station = ForeignKey(Station, on_delete=models.CASCADE)
    begin_date = models.DateTimeField()
    x = models.FloatField(null=True, blank=True)
    y = models.FloatField(null=True, blank=True)
    o_x = models.FloatField(null=True, blank=True)
    o_y = models.FloatField(null=True, blank=True)
    g_x = models.FloatField(null=True, blank=True)
    g_y = models.FloatField(null=True, blank=True)

    features = ArrayField(
        models.FloatField(),
        null=True,
        size=10,
    )
    
    magnitud = models.FloatField(null=True)
    
    
    values = ArrayField(
        models.FloatField(),
        size=365,
    )
    smoothedValues = ArrayField(
        models.FloatField(),
        size=365,
    )

    def dataset(self):
        return self.station.dataset