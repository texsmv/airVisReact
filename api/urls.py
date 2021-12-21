from django.urls import path
from .views import AnnualWindowsView, d3Tuto, main, DatasetView, DatasetsListView, menu, summary, windowsData, menu, main_projection, pollutant_projection

urlpatterns = [
    path('main/<str:dataset_id>/', main, name='main'),
    path('main/projection/<str:dataset_id>/<str:alphas>/', main_projection, name='mainProjection'),
    path('main/pollutant_projection/<str:dataset_id>/<str:pollutant_id>/', pollutant_projection, name='pollutantProjection'),
    path('', menu, name='menu'),
    path('summary', summary, name='summary'),
    path('d3', d3Tuto, name='d3tuto'),
    path('datasets', DatasetView.as_view(), name='datasets'),
    # path('windows', AnnualWindowsView.as_view(), name='windows'),
    path('windows/<str:dataset_id>/', windowsData, name='windows'),
    path('datasetsList', DatasetsListView.as_view(), name='datasetsList'),
]