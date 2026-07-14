import requests as _requests

API_BASE = 'http://127.0.0.1:8000/api'


def _headers(request):
    token = request.session.get('api_token', '')
    h = {'Content-Type': 'application/json'}
    if token:
        h['Authorization'] = f'Token {token}'
    return h


def get(request, endpoint, params=None):
    return _requests.get(f'{API_BASE}{endpoint}', headers=_headers(request), params=params, timeout=10)


def post(request, endpoint, data=None):
    return _requests.post(f'{API_BASE}{endpoint}', json=data or {}, headers=_headers(request), timeout=10)


def put(request, endpoint, data=None):
    return _requests.put(f'{API_BASE}{endpoint}', json=data or {}, headers=_headers(request), timeout=10)


def patch(request, endpoint, data=None):
    return _requests.patch(f'{API_BASE}{endpoint}', json=data or {}, headers=_headers(request), timeout=10)


def delete(request, endpoint):
    return _requests.delete(f'{API_BASE}{endpoint}', headers=_headers(request), timeout=10)


def safe_json(response, default=None):
    try:
        return response.json()
    except Exception:
        return default if default is not None else {}
