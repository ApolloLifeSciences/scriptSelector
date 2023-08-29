#Authors: Lukas Vaut and Christian Dammann, 2023
from datetime import datetime, timedelta
from pathlib import Path
import os, json, sys, shutil, inquirer, ctypes,time,traceback, re, csv
from inquirer.themes import GreenPassion
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.backends.backend_pdf import PdfPages
import numpy as np

def returnPositionDictFromFilename(filename):
    try:
        positionString = re.findall('_P[0-9]+X_', filename)
        positionNumber = int(positionString[0].replace('_P','').replace('X_',''))

        arrayNameString = re.findall('_[a-zA-Z0-9]+'+positionString[0],filename)
        arrayName = arrayNameString[0].replace(positionString[0],'').replace('_','')

        roundNumberString = re.findall(positionString[0]+'R[0-9]+_',filename)
        roundNumber = int(roundNumberString[0].replace(positionString[0],'').replace('R','').replace('_',''))

        channelNameString = re.findall(positionString[0]+'R'+str(roundNumber)+'_RO-Channel[a-zA-Z]*[0-9]',filename)
        ROChannelNumber = int(channelNameString[0][-1])

        lockStateBool = False            
        lockStateSearch =  re.findall('_RO-ChannelLOCK', filename)
        if len(lockStateSearch) !=0: lockStateBool = True

        ignoredatBool = False            
        ignoredatSearch =  re.findall('_IGNOREDAT', filename)
        if len(ignoredatSearch) !=0: ignoredatBool = True
                
        return {'positionNumber':int(positionNumber), 'arrayName': arrayName,'roundNumber':roundNumber, 'ignoredat': ignoredatBool, 'ROChannelNumber': int(ROChannelNumber),'lockStateBool':lockStateBool}
    except:
        return None

def AllFilesThatContainSubstringsInListOfStrings(mylist, substrings, ending = ".tiff"):
    try:
        matchingFiles = []
        filenames = mylist
        for filename in filenames:
            if not filename.endswith(ending):
                continue
            else:
                if areAllSubstringsInString(filename, substrings):
                    matchingFiles += [filename]
        return matchingFiles
    except:
        return []

def areAllSubstringsInString(mystring, substrings):
    try:
        matchcounts = 0
        for iii in range(0,len(substrings)):
            if mystring.find(substrings[iii]) !=-1:
                matchcounts += 1
        if matchcounts == len(substrings):
            return True
        else:
            return False
    except:
        return False


pyfilefolderpath = os.path.dirname(__file__)
expFolder = os.path.abspath(os.path.join(pyfilefolderpath, os.pardir))
preprocessingFolder = os.path.join(expFolder, 'preprocessing')
# spotcounter
print('listing all files in preprocessing')
#files = [ file for file in os.listdir(os.path.join(folder,'preprocessing')) if os.path.isfile(os.path.join(folder,'preprocessing',file))]
filesAll = [ file for file in os.listdir(os.path.join(expFolder,'preprocessing')) if file.endswith('_feat.txt')]

print('listing all files in preprocessing done')

if True:
    try:
        files = [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
        for myfile in filesAll:
            round = int(myfile.split('X_R',1)[1].split('_RO-Channel',1)[0])
            files[round-1].append(myfile)
        print(files)
        for iii in [1,2,3,4,5,6,7,8]:
            try:
                imagingData = {}
                for lll, myfile in enumerate(files[iii-1]):
                    #print('img protocol '+str(iii)+': file '+str(lll))
                    fileDict = returnPositionDictFromFilename(myfile)
                    if fileDict is not None:
                        if int(fileDict['roundNumber']) == iii:
                            currentKey = fileDict['arrayName']+'P'+str(fileDict['positionNumber'])+'R'+str(iii)
                            token = fileDict['arrayName']+'_P'+str(fileDict['positionNumber'])+'X_R'+str(iii)
                            for channelNumber in [1,2]:
                                matches = AllFilesThatContainSubstringsInListOfStrings(files[iii-1], substrings=[token, 'RO-Channel'+str(channelNumber), '_feat'], ending='txt')
                                try:
                                    for myotherfile in matches:
                                        counter = [0 for ccc in range(0,32)]
                                        pathToFile = os.path.join(expFolder,'preprocessing',myotherfile)
                                        with open(pathToFile, 'r') as file:
                                            allLines = csv.reader(file, delimiter='\t')
                                            for line in allLines:
                                                counter[int(line[2])] += 1
                                        if not currentKey in imagingData.keys():
                                            imagingData[currentKey] = {}
                                        if not 'preprocessing' in imagingData[currentKey].keys():
                                            imagingData[currentKey]['preprocessing'] = {}
                                        imagingData[currentKey]['preprocessing'].update({'cumulativeROChannel'+str(channelNumber):counter})
                                        imagingData[currentKey]['ArrayName'] = fileDict['arrayName']
                                        imagingData[currentKey]['PositionName'] = fileDict['positionNumber']
                                        imagingData[currentKey]['RoundNumber'] = fileDict['roundNumber']

                                except:
                                    print(traceback.format_exc())
                if not os.path.exists(os.path.join(expFolder,'analysis')): os.makedirs(os.path.join(expFolder,'analysis'))
                with open(os.path.join(expFolder,'analysis','imagingProtocol_round_analyzed'+str(iii)+'.json'), 'w') as jsonfileOut:
                    json.dump(imagingData, jsonfileOut)
            except:
                print(traceback.format_exc())
                continue
    except:
        pass


    
if True:
    try:
        csvFolder = os.path.join(expFolder,'analysis', 'csv')
        if not os.path.isdir(csvFolder):
            os.makedirs(csvFolder) 
        for iii in [1,2,3,4,5,6,7,8]:
            try:
                with open(os.path.join(expFolder,'analysis','imagingProtocol_round_analyzed'+str(int(iii))+'.json')) as jsonfile:
                    imagingProtocol = json.load(jsonfile)  
                allArrayNames = []
                for key in imagingProtocol.keys():
                    allArrayNames.append(imagingProtocol[key]['ArrayName'])
                allArrayNames = list(dict.fromkeys(allArrayNames))
                for key in imagingProtocol.keys():
                        for channel in [1,2]:
                            try:
                                #print(os.path.join(expFolder,'analysis', 'csv','R'+str(imagingProtocol[key]['RoundNumber'])+'_'+str(imagingProtocol[key]['ArrayName'])+'_Channel'+str(channel)+'.txt'))
                                log = open(os.path.join(expFolder,'analysis', 'csv','R'+str(imagingProtocol[key]['RoundNumber'])+'_'+str(imagingProtocol[key]['ArrayName'])+'_Channel'+str(channel)+'.txt'),"a")
                                ChannelLine = ''
                                for entry in imagingProtocol[key]['preprocessing']['cumulativeROChannel'+str(channel)]:
                                    ChannelLine += str(entry)+'\t'
                                log.write('%s' % '\t'.join(map(str,[str(imagingProtocol[key]['ArrayName']),str(imagingProtocol[key]['PositionName']), str(ChannelLine)]))+"\n")
                                log.close()
                            except:
                                continue
            except:
                print(traceback.format_exc())
                continue
                

    except:
        pass

if False:
    try:
        figures = []
        RoundNumber = 1
        print(os.path.join(expFolder,'imagingConfig','protocol','imagingProtocol_round_analyzed'+str(int(RoundNumber))+'.json'))
        with open(os.path.join(expFolder,'imagingConfig','protocol','imagingProtocol_round_analyzed'+str(int(RoundNumber))+'.json')) as jsonfile:
            imagingProtocol = json.load(jsonfile) 
        counter = 0
        for key in sorted(imagingProtocol.keys()):
            try:
                fig, ax = plt.subplots()
                counter += 1
                if counter > 1000:
                    break
                for channelNumber in [1,2]:
                    y = imagingProtocol[key]['preprocessing']['cumulativeROChannel'+str(channelNumber)]
                    x = range(0,len(y))
                    plt.scatter(x,y)
                plt.title(key)
                #plt.show()
                figures.append(fig)
            except:
                continue
        plotfolder = os.path.join(expFolder, 'analysis')
        if not os.path.isdir(plotfolder):
            os.makedirs(plotfolder)    
        with PdfPages(os.path.join(plotfolder, 'cumulativeSpots_vs_slice_plain.pdf')) as outputpdf:
            for figure in figures:
                outputpdf.savefig(figure)
                plt.close()
    except:
        print(traceback.format_exc())
