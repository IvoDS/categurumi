const CACHE_NAME = 'categurumi-image-cache-v1';
const IMAGE_URL_PATTERN = /\/storage\//;

self.addEventListener('install', (event) => {
    self.skipWaiting();
});

self.addEventListener('activate', (event) => {
    event.waitUntil(clients.claim());
});

self.addEventListener('fetch', (event) => {
    const { request } = event;

    // Only handle GET requests for images in the storage folder
    if (request.method === 'GET' && IMAGE_URL_PATTERN.test(request.url)) {
        event.respondWith(
            caches.match(request).then((cachedResponse) => {
                if (cachedResponse) {
                    return cachedResponse;
                }

                return fetch(request).then((response) => {
                    // Check if we received a valid response
                    if (!response || response.status !== 200 || response.type !== 'basic') {
                        // Note: If images are on a different domain, type would be 'opaque'
                        // but since they are served via /storage on the same domain, 'basic' is expected.
                        // However, we still cache them if it's a valid successful fetch.
                    }
                    
                    const responseToCache = response.clone();
                    caches.open(CACHE_NAME).then((cache) => {
                        cache.put(request, responseToCache);
                    });

                    return response;
                });
            })
        );
    }
});
