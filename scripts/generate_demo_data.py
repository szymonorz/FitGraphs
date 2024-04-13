import json
from random import gauss, uniform, choice
from datetime import datetime, timedelta
from dataclasses import dataclass, field

@dataclass
class Activity():
    name: str = ""
    distance: int = 0
    moving_time: int = 0
    elapsed_time: int = 0
    total_elevation_gain: int = 0
    type: str = ""
    sport_type: str = ""
    id: int = 0
    start_date: str = ""
    start_date_local: str = ""
    timezone: str = ""
    utc_offset: int = 0
    start_latlng: list[float] = field(default_factory=lambda: [0.0, 0.0])
    end_latlng: list[float] = field(default_factory=lambda: [0.0, 0.0])
    location_country: str = "Poland"
    average_speed: float = 0.0
    max_speed: float = 0.0
    average_cadence: float = 0.0
    average_watts: float = 0.0
    weighted_average_watts: float = 0.0
    kilojoules: float = 0.0
    device_watts: float = 0.0
    has_heartrate: bool = True
    average_heartrate: float = 0.0
    max_heartrate: float = 0.0
    max_watts: float = 0.0

def generate_data(n):
    d1 = datetime.strptime('1/1/2023', '%d/%m/%Y')

    name_choices_prefixes = ["Evening", "Afternoon", "Morning"]
    sport_type_choices = ["Ride", "Swim", "Run"]
    run_distance = 7
    ride_distance = 10
    swim_distance = 5

    # Simulating some variability in performance metrics
    base_speed = {'Run': 11/3.6, 'Ride': 25/3.6, 'Swim': 2/3.6}  # in km/h
    base_cadence = {'Run': 80, 'Ride': 90, 'Swim': 60}
    activities = []
    for i in range(n):
        activity = Activity()
        activity.type = choice(sport_type_choices)
        activity.sport_type = activity.type

        if i % 30 == 0:
            if activity.type == "Run":
                run_distance += 2
            if activity.type == "Ride":
                ride_distance += 5
            if activity.type == "Swim":
                swim_distance += 1

        activity.distance = {'Run': run_distance, 'Ride': ride_distance, 'Swim': swim_distance}[activity.type]
        activity.name = f"{choice(name_choices_prefixes)} {activity.type}"
        activity.start_date_local = (d1 + timedelta(days=i)).strftime("%Y-%m-%d %H:%M:%S")
        activity.start_date = activity.start_date_local

        activity.moving_time = int(activity.distance / base_speed[activity.type] * 3600)  # in seconds
        activity.elapsed_time = int(activity.moving_time * uniform(1.1, 1.3))  # adding some random stops or breaks
        activity.total_elevation_gain = int(gauss(20, 10) if activity.type in ['Run', 'Ride'] else 0)
        activity.average_speed = gauss(base_speed[activity.type], base_speed[activity.type] * 0.1)
        activity.max_speed = activity.average_speed * uniform(1.1, 1.3)
        activity.average_cadence = gauss(base_cadence[activity.type], 5)
        activity.average_heartrate = gauss(140, 10)
        activity.max_heartrate = activity.average_heartrate + uniform(10, 20)
        activity.average_watts = gauss(200, 50) if activity.type == 'Ride' else 0
        activity.max_watts = activity.average_watts * uniform(1.1, 1.5)

        activities.append(activity)

    return activities

data = generate_data(360)

with open("activties_demo.json", "w", encoding="utf-8") as f:
    json.dump(data, f, default=lambda o: o.__dict__)
