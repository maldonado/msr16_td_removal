/*
 * Copyright (C) The Apache Software Foundation. All rights reserved.
 *
 * This software is published under the terms of the Apache Software License
 * version 1.1, a copy of which has been included with this distribution in
 * the LICENSE.txt file.
 */
package org.apache.tools.ant.types;// java io classes

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Properties;
import org.apache.myrmidon.api.TaskException;
import org.apache.tools.ant.ProjectComponent;

/**
 * A set of filters to be applied to something. A filter set may have begintoken
 * and endtokens defined.
 *
 * @author <A href="mailto:gholam@xtra.co.nz"> Michael McCallum </A>
 * @created 14 March 2001
 */
public class FilterSet
    extends ProjectComponent
    implements Cloneable
{

    /**
     * The default token start string
     */
    public final static String DEFAULT_TOKEN_START = "@";

    /**
     * The default token end string
     */
    public final static String DEFAULT_TOKEN_END = "@";

    private String m_startOfToken = DEFAULT_TOKEN_START;
    private String m_endOfToken = DEFAULT_TOKEN_END;

    /**
     * List of ordered filters and filter files.
     */
    private ArrayList m_filters = new ArrayList();

    public FilterSet()
    {
    }

    /**
     * Create a Filterset from another filterset
     *
     * @param filterset the filterset upon which this filterset will be based.
     */
    protected FilterSet( FilterSet filterset )
        throws TaskException
    {
        super();
        m_filters = (ArrayList)filterset.getFilters().clone();
    }

    /**
     * The string used to id the beginning of a token.
     *
     * @param startOfToken The new Begintoken value
     */
    public void setBeginToken( String startOfToken )
        throws TaskException
    {
        if( startOfToken == null || "".equals( startOfToken ) )
        {
            throw new TaskException( "beginToken must not be empty" );
        }
        m_startOfToken = startOfToken;
    }

    /**
     * The string used to id the end of a token.
     *
     * @param endOfToken The new Endtoken value
     */
    public void setEndToken( String endOfToken )
        throws TaskException
    {
        if( endOfToken == null || "".equals( endOfToken ) )
        {
            throw new TaskException( "endToken must not be empty" );
        }
        m_endOfToken = endOfToken;
    }

    /**
     * set the file containing the filters for this filterset.
     *
     * @param filtersFile sets the filter fil to read filters for this filter
     *      set from.
     * @exception TaskException if there is a problem reading the filters
     */
    public void setFiltersfile( File filtersFile )
        throws TaskException
    {
        readFiltersFromFile( filtersFile );
    }

    public String getBeginToken()
    {
        return m_startOfToken;
    }

    public String getEndToken()
    {
        return m_endOfToken;
    }

    /**
     * Gets the filter hash of the FilterSet.
     *
     * @return The hash of the tokens and values for quick lookup.
     */
    public Hashtable getFilterHash()
        throws TaskException
    {
        int filterSize = getFilters().size();
        Hashtable filterHash = new Hashtable( filterSize );
        for( Iterator e = getFilters().iterator(); e.hasNext(); )
        {
            Filter filter = (Filter)e.next();
            filterHash.put( filter.getToken(), filter.getValue() );
        }
        return filterHash;
    }

    /**
     * Create a new filter
     *
     * @param filter The feature to be added to the Filter attribute
     */
    public void addFilter( Filter filter )
    {
        m_filters.add( filter );
    }

    /**
     * Add a new filter made from the given token and value.
     *
     * @param token The token for the new filter.
     * @param value The value for the new filter.
     */
    public void addFilter( String token, String value )
    {
        m_filters.add( new Filter( token, value ) );
    }

    /**
     * Add a Filterset to this filter set
     *
     * @param filterSet the filterset to be added to this filterset
     */
    public void addFilterSet( FilterSet filterSet )
    {
        for( Iterator e = filterSet.getFilters().iterator(); e.hasNext(); )
        {
            m_filters.add( (Filter)e.next() );
        }
    }

    /**
     * Create a new FiltersFile
     *
     * @return The filter that was created.
     */
    public FiltersFile createFiltersfile()
    {
        return new FiltersFile();
    }

    /**
     * Test to see if this filter set it empty.
     *
     * @return Return true if there are filter in this set otherwise false.
     */
    public boolean hasFilters()
        throws TaskException
    {
        return getFilters().size() > 0;
    }

    /**
     * Read the filters from the given file.
     *
     * @param filtersFile the file from which filters are read
     * @exception TaskException Throw a build exception when unable to read the
     *      file.
     */
    public void readFiltersFromFile( File filtersFile )
        throws TaskException
    {
        if( filtersFile.isFile() )
        {
            getLogger().debug( "Reading filters from " + filtersFile );
            FileInputStream in = null;
            try
            {
                Properties props = new Properties();
                in = new FileInputStream( filtersFile );
                props.load( in );

                Enumeration enum = props.propertyNames();
                ArrayList filters = getFilters();
                while( enum.hasMoreElements() )
                {
                    String strPropName = (String)enum.nextElement();
                    String strValue = props.getProperty( strPropName );
                    filters.add( new Filter( strPropName, strValue ) );
                }
            }
            catch( Exception e )
            {
                throw new TaskException( "Could not read filters from file: " + filtersFile );
            }
            finally
            {
                if( in != null )
                {
                    try
                    {
                        in.close();
                    }
                    catch( IOException ioex )
                    {
                    }
                }
            }
        }
        else
        {
            throw new TaskException( "Must specify a file not a directory in the filtersfile attribute:" + filtersFile );
        }
    }

    /**
     * Does replacement on the given string with token matching. This uses the
     * defined begintoken and endtoken values which default to @ for both.
     *
     * @param line The line to process the tokens in.
     * @return The string with the tokens replaced.
     */
    public String replaceTokens( String line )
        throws TaskException
    {
        String beginToken = getBeginToken();
        String endToken = getEndToken();
        int index = line.indexOf( beginToken );

        if( index > -1 )
        {
            Hashtable tokens = getFilterHash();
            try
            {
                StringBuffer b = new StringBuffer();
                int i = 0;
                String token = null;
                String value = null;

                do
                {
                    int endIndex = line.indexOf( endToken, index + beginToken.length() + 1 );
                    if( endIndex == -1 )
                    {
                        break;
                    }
                    token = line.substring( index + beginToken.length(), endIndex );
                    b.append( line.substring( i, index ) );
                    if( tokens.containsKey( token ) )
                    {
                        value = (String)tokens.get( token );
                        getLogger().debug( "Replacing: " + beginToken + token + endToken + " -> " + value );
                        b.append( value );
                        i = index + beginToken.length() + token.length() + endToken.length();
                    }
                    else
                    {
                        // just append beginToken and search further
                        b.append( beginToken );
                        i = index + beginToken.length();
                    }
                } while( ( index = line.indexOf( beginToken, i ) ) > -1 );

                b.append( line.substring( i ) );
                return b.toString();
            }
            catch( StringIndexOutOfBoundsException e )
            {
                return line;
            }
        }
        else
        {
            return line;
        }
    }

    protected ArrayList getFilters()
    {
        return m_filters;
    }

    /**
     * The filtersfile nested element.
     *
     * @author Michael McCallum
     * @created Thursday, April 19, 2001
     */
    public class FiltersFile
    {
        /**
         * Constructor for the Filter object
         */
        public FiltersFile()
        {
        }

        /**
         * Sets the file from which filters will be read.
         *
         * @param file the file from which filters will be read.
         */
        public void setFile( File file )
            throws TaskException
        {
            readFiltersFromFile( file );
        }
    }

}


