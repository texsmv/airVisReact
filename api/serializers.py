from rest_framework import serializers
from .models import Dataset, Station, AnnualWindow

# Dataset serializer
class DatasetSerializer(serializers.ModelSerializer):
    class Meta:
        model = Dataset
        fields = ('id', 'name')


# Station serializer
class StationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Station
        fields = ('id', 'name', 'dataset')


class AnnualWindowSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnnualWindow
        fields = ('id', 'pollutant', 'station', 'begin_date', 'x', 'y', 'values', 'smoothedValues')