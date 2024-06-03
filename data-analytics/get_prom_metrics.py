import csv
from datetime import datetime, timedelta, timezone
import requests
from urllib.parse import urljoin

prometheus_url = 'http://<Prometheus IP>:9999'

# Экспортируются все метрики, собранные за последние delta минут
delta: int = 30
end_time = datetime.now(timezone.utc)
start_time = end_time - timedelta(minutes=delta)

# Конвертируем время в нужный формат
start = start_time.isoformat().replace("+00:00", "Z")
end = end_time.isoformat().replace("+00:00", "Z")

step = '1m'

queries = {
    'CPU': 'sum(rate(container_cpu_usage_seconds_total{name=~".+"}' + f'[{step}])) by (name) * 100',
    'Net_received': 'sum by (name) (rate(container_network_receive_bytes_total{name=~".+"}' + f'[{step}]))',
    'Net_sent': 'sum(rate(container_network_transmit_bytes_total{name=~".+"}' + f'[{step}])) by (name)',
    'RAM': 'sum(container_memory_rss{name=~".+"}) by (name)'
}

step_int = int(step[:1])

def save_to_csv(datas, queries, filename1):
    with open(filename1, 'w', newline='') as file:
        writer = csv.writer(file)
        names = ['Timestamp']
        for i in range(int(delta / step_int) + 1):
            names.append(str(start_time + timedelta(minutes=i)))
        writer.writerow(names)

        for dt in range(len(datas)):
            for j in range(len(datas[dt])):
                item = datas[dt][j]
                keys = list(queries.keys())
                suffix = keys[dt]
                row = [item['metric'].get('name', '') + f"_{suffix}"] + [x[1] for x in item['values']]
                writer.writerow(row)


def query_range(query, start, end, step, timeout=None):
    params = {'query': query, 'start': start, 'end': end, 'step': step}
    if timeout:
        params['timeout'] = timeout

    url = urljoin(prometheus_url, 'api/v1/query_range')
    response = requests.get(url, params=params)

    if response.status_code != 200:
        response.raise_for_status()

    data = response.json()
    if data['status'] != 'success':
        raise RuntimeError(f"{data['errorType']}: {data['error']}")

    return data['data']['result']


try:
    datas = []
    for query in queries.values():
        data = query_range(query, start, end, step)
        datas.append(data)
    save_to_csv(datas, queries, f"output.csv")

except Exception as e:
    print(f"An error occurred: {e}")
