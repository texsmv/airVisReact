from django.http.response import HttpResponse
from django.shortcuts import render
from rest_framework import generics
from .serializers import DatasetSerializer, AnnualWindowSerializer
from api.models import AnnualWindow, Dataset

class DatasetView(generics.ListAPIView):
    queryset = Dataset.objects.all()
    serializer_class = DatasetSerializer

class AnnualWindowsView(generics.ListAPIView):
    queryset = AnnualWindow.objects.all()[:100]
    serializer_class = AnnualWindowSerializer


def main(request):
    context = {
        'jsonD': AnnualWindowsView.queryset
    }
    return render(request, 'api/home.html', context)

def d3Tuto(request):
    return render(request, 'api/d3tuto.html')
