graph TD;
    A[Users] -->|Access| B[Web Application];
    B -->|Fetch Data| C[Microservices];
    C -->|Query| D[Database];
    D -->|Return Data| C;
    C -->|Send Data| B;
    B -->|Display| A;
    B -->|Monitor| E[Monitoring Service];
    E -->|Alerts| F[Response Team];
    G[API Gateway] -->|Route| B;
    B -->|Authenticate| H[Identity Provider];