from django.http.response import HttpResponse
from django.shortcuts import render
from rest_framework import generics
from .serializers import DatasetSerializer, AnnualWindowSerializer
from api.models import AnnualWindow, Dataset

class DatasetView(generics.ListAPIView):
    queryset = Dataset.objects.all()
    serializer_class = DatasetSerializer

class AnnualWindowsView(generics.ListAPIView):
    queryset = AnnualWindow.objects.all()[:5]
    serializer_class = AnnualWindowSerializer


def main(request):
    return HttpResponse('Hello')
    return render(request, 'main.html')
