package com.danrdev.item.config;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.io.IOException;

@Component
public class RequestResponseLoggingFilter implements Filter {

    private static final Logger logger = LoggerFactory.getLogger(RequestResponseLoggingFilter.class);

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        ContentCachingResponseWrapper responseWrapper = new ContentCachingResponseWrapper(httpResponse);

        logger.info("Request Method: {}, Request URI: {}", httpRequest.getMethod(), httpRequest.getRequestURI());

        chain.doFilter(request, responseWrapper);

        byte[] responseBody = responseWrapper.getContentAsByteArray();
        logger.info("Response Status: {}", httpResponse.getStatus());
        logger.info("Response Body: {}", new String(responseBody));

        responseWrapper.copyBodyToResponse();
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void destroy() {
    }
}
