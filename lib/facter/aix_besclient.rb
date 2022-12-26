#
#  FACT(S):     aix_besclient
#
#  PURPOSE:     This custom fact returns a complex fact hash that can be used
#		to fill in the AIX BESClient web page in the dashboard.
#
#  RETURNS:     (hash)
#
#  AUTHOR:      Chris Petersen, Crystallized Software
#
#  DATE:        February 9, 2021
#
#  NOTES:       Myriad names and acronyms are trademarked or copyrighted by IBM
#               including but not limited to IBM, PowerHA, AIX, RSCT (Reliable,
#               Scalable Cluster Technology), and CAA (Cluster-Aware AIX).  All
#               rights to such names and acronyms belong with their owner.
#
#-------------------------------------------------------------------------------
#
#  LAST MOD:    (never)
#
#  MODIFICATION HISTORY:
#
#       (none)
#
#-------------------------------------------------------------------------------
#
Facter.add(:aix_besclient) do
    #  This only applies to the AIX operating system
    confine :osfamily => 'AIX'

    #  Define an somewhat empty hash for our output
    l_aixBESClient                     = {}
    l_aixBESClient['running']          = false
    l_aixBESClient['version']          = ''

    #  Do the work
    setcode do
        #  Run the command to look through the process list for the Tidal daemon
        l_lines = Facter::Util::Resolution.exec('/bin/ps -ef 2>/dev/null')

        #  Loop over the lines that were returned
        l_lines && l_lines.split("\n").each do |l_oneLine|
            #  Skip comments and blanks
            l_oneLine = l_oneLine.strip()
            #  Look for a telltale and rip apart that line
            if (l_oneLine =~ /\/opt\/BESClient\/bin\/BESClient/)
                #  If we found this in "ps" output, then we're definitly running
                l_aixBESClient['running'] = true
            end
        end


        #  Run the command to list the history of the bos.mp64 package
        l_lines = Facter::Util::Resolution.exec('/bin/lslpp -hc BESClient 2>/dev/null')

        #  Loop over the lines that were returned
        l_lines && l_lines.split("\n").each do |l_oneLine|
            #  Skip comments and blanks
            l_oneLine = l_oneLine.strip()
            next if l_oneLine =~ /^#/ or l_oneLine =~ /^$/

            #  Split regular lines, and stash the relevant fields - last line is what we really want
            l_list = l_oneLine.split(':')
            l_aixBESClient['version']  = l_list[2]
        end

        #  Implicitly return the contents of the variable
        l_aixBESClient
    end
end
