from django.http.response import HttpResponse
from django.shortcuts import render
from rest_framework import generics
from scipy.sparse import data
from .serializers import DatasetSerializer, AnnualWindowSerializer
from api.models import AnnualWindow, Dataset, Pollutant, Station
from django.views.generic import ListView
from django.core import serializers
from django.http import JsonResponse
from sklearn.preprocessing import minmax_scale

import json
import numpy as np
import umap

def scale_layout2(points, bound=[-1, 1]):
    p_min = np.min(points, axis=0)
    p_max = np.max(points, axis=0)

    w = p_max[0] - p_min[0]
    h = p_max[1] - p_min[1]
    d = max([w, h])

    s = 1.0
    if d > 0:
        s = (bound[1] - bound[0]) / d
    offset = [(d - w) * .5, (d - h) * .5]

    return bound[0] + (offset + points - p_min) * s

def scale_layout(points, bound=[-1, 1]):
    coordinates_x = points[:, 0]
    coordinates_y = points[:, 1]
    coordinates_x = scale_array(coordinates_x, bound)
    coordinates_y = scale_array(coordinates_y, bound)
    return np.array([coordinates_x, coordinates_y]).T

def scale_array(arr, bound=[-1, 1]):
    arr_min = np.min(arr)
    arr_max = np.max(arr)

    w = arr_max - arr_min
    d = max([w])

    s = 1.0
    if d > 0:
        s = (bound[1] - bound[0]) / d
    offset = (d - w) * .5

    return bound[0] + (offset + arr - arr_min) * s

class DatasetsListView(ListView):
    model = Dataset

    def get_queryset(self):
        return Dataset.objects.all()
    

class DatasetView(generics.ListAPIView):
    queryset = Dataset.objects.all()
    serializer_class = DatasetSerializer

class AnnualWindowsView(generics.ListAPIView):
    queryset = AnnualWindow.objects.all()
    serializer_class = AnnualWindowSerializer

def menu(request):
    context={
        'datasets': Dataset.objects.all(),
    }
    
    return render(request, 'api/menu.html', context)

def all_datasets(request):
    data = Dataset.objects.all()
    return JsonResponse(
        {'data': serializers.serialize('json', data)}, 
        safe=False
    )

def main_projection(request, dataset_id, alphas, ratio):
    ratio = float(ratio)
    alphas_list = alphas.split(',')
    alphas_list = [float(alpha.strip()) for alpha in alphas_list]

    dataset = Dataset.objects.get(pk = dataset_id)

    firstPollutant = Pollutant.objects.filter(dataset=dataset)[0]
    windowsAll = AnnualWindow.objects.filter(pollutant=firstPollutant, station__dataset=dataset)
    n = len(windowsAll)

    pollutants = Pollutant.objects.filter(dataset = dataset)

    distm_shape = {}
    distm_mean = {}
    distm = np.zeros((n, n))

    for pollutant in pollutants:
        distm_shape[pollutant.name] = np.zeros((n, n))
        distm_mean[pollutant.name] = np.zeros((n, n))
    
    for pollutant in pollutants:
        windows = AnnualWindow.objects.filter(pollutant=pollutant, station__dataset=dataset)
        n = len(windows)
        for i in range(n):
            for j in range(n):
                distm_shape[pollutant.name][i, j] = np.linalg.norm(np.array(windows[i].features) - np.array(windows[j].features))
                distm_mean[pollutant.name][i, j] = np.linalg.norm(windows[i].magnitud - windows[j].magnitud)

    alphas = { pollutants[i].name: alphas_list[i] for i in range(len(pollutants)) }

    # ratio = 0.5

    for pollutant in pollutants:
        for i in range(n):
            for j in range(n):
                distm[i, j] += ratio * alphas[pollutant.name] * distm_shape[pollutant.name][i, j] + (1 - ratio) * alphas[pollutant.name] *  distm_mean[pollutant.name][i, j]
                
    
    transformer = umap.UMAP(metric='precomputed', n_components=2)
    coordinates = transformer.fit_transform(distm)
    coordinates = scale_layout(coordinates)

    return JsonResponse(json.dumps(coordinates.tolist()), safe=False)

def pollutant_projection(request, dataset_id, pollutant_id):
    dataset = Dataset.objects.get(pk = dataset_id)

    pollutant = Pollutant.objects.get(pk = pollutant_id)
    windows = AnnualWindow.objects.filter(pollutant=pollutant, station__dataset=dataset)
    n = len(windows)

    dist_shape = np.zeros((n, n))
    coordinates = np.zeros((n, 2))
    series = np.zeros((n, 365))

    n = len(windows)
    for i in range(n):
        series[i] = windows[i].values
        coordinates[i][1] = windows[i].magnitud
        for j in range(n):
            dist_shape[i, j] = np.linalg.norm(np.array(windows[i].features) - np.array(windows[j].features))

    transformer = umap.UMAP(metric='precomputed', n_components=1)
    shapeDescr = transformer.fit_transform(dist_shape)
    for i in range(n):
        coordinates[i][0] = shapeDescr[i]
    print(coordinates)
    coordinates = scale_layout(coordinates)
    print(coordinates)
    print(coordinates.min())
    print(coordinates.max())

    data = {
        'coordenates': coordinates.tolist(),
        'series': series.tolist()
    }
    return JsonResponse(json.dumps(data), safe=False)

    

def main(request, dataset_id):
    dataset = Dataset.objects.get(pk = dataset_id)
    pollutants = Pollutant.objects.filter(dataset=dataset)
    stations = Station.objects.filter(dataset=dataset)
    firstPollutant = pollutants[0]
    windows = AnnualWindow.objects.filter(station__dataset=dataset, pollutant=firstPollutant, station=stations[0])

    dates = [window.begin_date.year for window in windows]
    min_year = min(dates)
    max_year = max(dates)
    years = [i for i in range(min_year, max_year + 1) ]
    print(years)
    
    return JsonResponse(
        {
            'years':json.dumps(years),
            'pollutants': serializers.serialize('json', pollutants),
            'stations': serializers.serialize('json', stations),
        },
        safe=False
    )

    context = {
        'dataset': dataset,
        'pollutants': pollutants,
        'selected_pollutant': firstPollutant,
        'stations': stations,
        'years': years,
    }
    return render(request, 'api/home.html', context)

def windowsData(request, dataset_id):
    dataset = Dataset.objects.get(pk = dataset_id)

    firstPollutant = Pollutant.objects.filter(dataset=dataset)[0]
    windowsAll = AnnualWindow.objects.filter(pollutant=firstPollutant, station__dataset=dataset)
    n = len(windowsAll)
    # embeddings = [window.embedding for window in windows]
    pollutants = Pollutant.objects.filter(dataset = dataset)

    distm_shape = {}
    distm_mean = {}
    distm = np.zeros((n, n))
    dists = np.zeros((n, n))

    for pollutant in pollutants:
        distm_shape[pollutant.name] = np.zeros((n, n))
        distm_mean[pollutant.name] = np.zeros((n, n))
    
    is_done = True
    coordinates2 = np.zeros((n, 2))
    for pollutant in pollutants:
        windows = AnnualWindow.objects.filter(pollutant=pollutant, station__dataset=dataset)
        n = len(windows)
        for i in range(n):
            if is_done:
                coordinates2[i][1] = windows[i].magnitud
            for j in range(n):
                distm_shape[pollutant.name][i, j] = np.linalg.norm(np.array(windows[i].features) - np.array(windows[j].features))
                distm_mean[pollutant.name][i, j] = np.linalg.norm(windows[i].magnitud - windows[j].magnitud)
        is_done = False

    alphas = { pollutants[i].name: 1.0 for i in range(len(pollutants)) }
    # alphas = {'NO_2':1.0, 'PM10':1.0, 'O_3':0.0, 'CO':0.0, 'SO_2':1.0}
    ratio = 0.5
    # sel = 'NO_2'
    sel = pollutants[0].name

    is_done = True
    for pollutant in pollutants:
        for i in range(n):
            for j in range(n):
                distm[i, j] += ratio * alphas[pollutant.name] * distm_shape[pollutant.name][i, j] + (1 - ratio) * alphas[pollutant.name] *  distm_mean[pollutant.name][i, j]
                if is_done:
                    dists[i, j] = distm_shape[sel][i, j]
        is_done = False
    
    transformer = umap.UMAP(metric='precomputed', n_components=2)
    coordinates = transformer.fit_transform(distm)

    transformer2 = umap.UMAP(metric='precomputed', n_components=1)
    shapeDescr = transformer2.fit_transform(dists)

    for i in range(n):
        coordinates2[i][0] = shapeDescr[i]
    
    print(coordinates2[:, 0].min())
    print(coordinates2[:, 0].max())
    print(coordinates[:, 0].min())
    print(coordinates[:, 0].max())
    print(coordinates2[:, 1].min())
    print(coordinates2[:, 1].max())
    print(coordinates[:, 1].min())
    print(coordinates[:, 1].max())


    coordinates = scale_layout(coordinates)
    coordinates2 = scale_layout(coordinates2)

    for i in range(n):
        windowsAll[i].g_x = coordinates[i][0]
        windowsAll[i].g_y = coordinates[i][1]
        windowsAll[i].x = coordinates2[i][0]
        windowsAll[i].y = coordinates2[i][1]
        windowsAll[i].save()
    print('=------=')

    print(coordinates2[:, 0].min())
    print(coordinates2[:, 0].max())
    print(coordinates[:, 0].min())
    print(coordinates[:, 0].max())
    print(coordinates2[:, 1].min())
    print(coordinates2[:, 1].max())
    print(coordinates[:, 1].min())
    print(coordinates[:, 1].max())

    return JsonResponse(
        {'data' : serializers.serialize('json', AnnualWindow.objects.filter(pollutant = firstPollutant))}, 
        safe=False
    )

def d3Tuto(request):
    return render(request, 'api/d3tuto.html')

def summary(request):
    dataset = Dataset.objects.all()[0]
    pollutants = Pollutant.objects.all()
    stations = Station.objects.filter(dataset=dataset)
    pollutant_dates={}
    curr_min_year = None
    curr_max_year = None
    for pollutant in pollutants:
        station_dates = {}
        for station in stations:
            windows = AnnualWindow.objects.filter(station__dataset=dataset, pollutant=pollutant, station=station)
            print(pollutant.name)
            # windows = AnnualWindow.objects.filter(pollutant=pollutant, station=station)
            dates = [window.begin_date.year for window in windows]
            if len(dates) != 0:
                min_year = min(dates)
                max_year = max(dates)
                if curr_min_year is None:
                    curr_min_year = min_year
                elif curr_min_year > min_year:
                    curr_min_year = min_year
                if curr_max_year is None:
                    curr_max_year = max_year
                elif curr_max_year < max_year:
                    curr_max_year = max_year
            station_dates[station.name] = dates
        pollutant_dates[pollutant.name] = station_dates

    curr_min_year = int(curr_min_year)
    curr_max_year = int(curr_max_year)
    
    pollutant_dates_map={}
    all_dates_range = [curr_min_year + i for i in range(curr_max_year - curr_min_year + 1)]
    for pollutant in pollutants:
        station_dates = {}
        for station in stations:
            dates = pollutant_dates[pollutant.name][station.name]
            dates = [int(date) for date in dates]
            dates_exist = []
            print(dates)
            for date in all_dates_range:
                if date in dates:
                    dates_exist.append([date, True])
                else:
                    dates_exist.append([date, False])
            station_dates[station.name] = dates_exist
        pollutant_dates_map[pollutant.name] = station_dates


    context = {
        'dataset': dataset,
        'pollutants': pollutants,
        'stations': stations,
        'dates': pollutant_dates_map,
        'min_year': curr_min_year,
        'max_year': curr_max_year,
    }
    return render(request, 'api/summary.html', context)
