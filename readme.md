# Exercise: Data Cleaning for IoT Sensors

In an IIoT application, we often receive data from various sensors and devices. This data can include various readings, some of which may be invalid or missing (bad values). Your task is to implement a function that takes in a JSON object or array representing sensor readings and returns a "cleaned" version of the data, with all bad values removed. This is important for ensuring that we only process meaningful data in our applications.

## Scenario

 Imagine you have a monitoring system that collects data from sensors deployed in a factory. The data can be represented as a JSON object or array, where some readings might be null, zero, or false, indicating that the sensor did not provide a valid reading.

## Function Requirements

Your function should:

- Accept an object or array as input.
- Remove all keys with bad values (null, false, empty objects, empty arrays, empty strings) from the object or array.
- Ensure that this operation applies to nested objects and arrays.
- Return the cleaned data in the same type as the input.

## Example Inputs and Outputs

### Example Input 1

```json
[null, 0, false, 1]
```

### Example Output 1

```json
 [0, 1]
 ```

### Example Input 2

```json
 [null, 0, 5, [false, 16]]
```

### Example Output 2

```json
[0, 5, [16]]
```

### Example Input 3

```json
{
  "sensorData": [
    {
      "sensorId": "sensor_1",
      "temperature": null,
      "humidity": 45,
      "status": "active",
      "location": "Zone A",
      "battery": 85,
      "lastUpdated": "2024-10-16T10:00:00Z"
    },
    {
      "sensorId": "",
      "temperature": 0,
      "humidity": [null, 50, 60],
      "status": "active",
      "location": "Zone E",
      "battery": 75,
      "lastUpdated": null
    },
    {
      "sensorId": "sensor_3",
      "temperature": 19,
      "humidity": false,
      "pressure": {
        "value": 1013,
        "units": "hPa"
      },
      "location": "Zone C",
      "battery": null,
      "lastUpdated": "2024-10-16T09:45:00Z"
    },
  ]
}
```

### Example Output 3

```json
{
  "sensorData": [
    {
      "sensorId": "sensor_1",
      "humidity": 45,
      "status": "active",
      "location": "Zone A",
      "battery": 85,
      "lastUpdated": "2024-10-16T10:00:00Z"
    },
    {
      "humidity": [50, 60],
      "status": "active",
      "location": "Zone E",
      "battery": 75
    },
    {
      "sensorId": "sensor_3",
      "temperature": 19,
      "pressure": {
        "value": 1013,
        "units": "hPa"
      },
      "location": "Zone C",
      "lastUpdated": "2024-10-16T09:45:00Z"
    }
  ]
}
```

## Constraints

The input is guaranteed to be a valid JSON object or array.

## Extensions

### Extension 1

The following endpoint contains all this data :<https://run.mocky.io/v3/ad4e525d-2f3b-45b7-acce-c514efa4cc5b>

### Extension 2

Make the function memoised

### Extension 3

Make the function memoised with a time limit
