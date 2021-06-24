function introspectAccessToken(r) {
    r.subrequest("/oauth2_send_request",
        function(reply) {
            if(reply.status === 200) {
                var response = JSON.parse(reply.responseBody);
                if(response.active == true) {
                    r.return(204);
                } else {
                    r.return(403);
                }
            } else {
                r.return(401);
            }
        }
    );
}