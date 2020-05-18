# Challenge goal
Create a server application that tracks sensor values submitted by one or more different client applications running on the same machine. A client can subsequently request previous values by signal name for a given sensor. Server and client are expected to be run under an embedded Linux environment with constrained resources, so care should be taken to be conservative of algorithms/libraries used. For this task, a test build running under macOS is also acceptable.

```mermaid
graph TD;
    Server<--SensorA;
    Server<--SensorB;
    Server<--SensorC;
    QueryClient<--Server;
```

# Expected deliverable
The deliverable for this task is a git repo (e.g. on Github or Gitlab) that is forked from the `service_challenge` repo (this repo) with sufficient documentation in a README to build and run the server/client applications to verify it’s functionality.

## Provided code
The build system, nanomsg, protobufs dependencies are setup in the existing repo. A `libsensorservice` has been 

# Requirements
You will be expected to add to the existing code and build:
* a server program 
* client/sensor programs
(modifying the build scripts as necessary to support those services).

# Must do requirements
* Server and client applications written in C++.
* Use Cmake build system for building and linking executables.
* Server application communicates with clients using nanomsg protocol and IPC sockets.
* Sensor readings are submitted with a signal name and value (32-bit float). Acknowledgement not required for submission of signal values.
* More than one client can be connected to the server simultaneously.
* Past sensor readings are stored with timestamps.
* A client can request the latest submitted value for a particular signal name.
* A client can query past values for a certain signal based on signal name and/or timestamps.
* Sensor data is persisted between server instances using SQLite database.


# Additional features - bonus points if you finish these as well
* Messages between server and client serialized using Google Protocol Buffers.
* Perform unit testing using a test framework such as Google Test
* Track signal “status” using boolean thresholding (i.e. have an signal exhibit an error condition if it’s value surpasses a configured level)

