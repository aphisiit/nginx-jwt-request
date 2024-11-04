function introspectAccessToken(r) {
    if(!r.headersIn.Authorization) {
        r.return(401);
        return;
    }

    r.subrequest("/oauth2_send_request",
        function(reply) {
            try {
                if(reply.status === 200) {
                    let response = JSON.parse(reply.responseText);
                    if(response.active === true) {
                        r.return(204);
                    } else {
                        r.return(403);
                    }
                } else {
                    r.return(401);
                }
            } catch (e) {
                console.error(e.message);
                r.return(500);
            }            
        }
    );
}

export default { introspectAccessToken };